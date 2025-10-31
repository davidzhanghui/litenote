<template>
  <div class="markdown-editor">
    <div v-if="filePath" class="editor-container">
      <!-- 工具栏 -->
      <div class="toolbar">
        <div class="file-info">
          <el-icon :size="18">
            <Document />
          </el-icon>
          <span class="file-name">{{ fileName }}</span>
          <el-tag 
            v-if="hasUnsavedChanges" 
            type="warning" 
            size="small"
            effect="dark"
          >
            未保存
          </el-tag>
          <el-tag 
            v-else
            type="success" 
            size="small"
            effect="dark"
          >
            已更新
          </el-tag>
        </div>
        <div class="actions">
          <el-button-group>
            <el-button 
              :type="viewMode === 'edit' ? 'primary' : ''"
              :icon="Edit"
              @click="viewMode = 'edit'"
            >
              编辑
            </el-button>
            <el-button 
              :type="viewMode === 'preview' ? 'primary' : ''"
              :icon="View"
              @click="viewMode = 'preview'"
            >
              预览
            </el-button>
            <el-button 
              :type="viewMode === 'split' ? 'primary' : ''"
              :icon="Connection"
              @click="viewMode = 'split'"
            >
              双栏
            </el-button>
          </el-button-group>
          <el-button 
            type="success" 
            :icon="DocumentChecked"
            @click="handleSave"
            :loading="saving"
          >
            保存
          </el-button>
          <el-button 
            type="primary" 
            :icon="Download"
            @click="handleDownload"
            title="下载源文件"
          >
            下载
          </el-button>
        </div>
      </div>

      <!-- 编辑/预览区域 -->
      <div class="content-area" :class="`mode-${viewMode}`">
        <!-- 编辑器 -->
        <div v-show="viewMode === 'edit' || viewMode === 'split'" class="editor-pane">
          <el-input
            v-model="editContent"
            type="textarea"
            :autosize="{ minRows: 20 }"
            placeholder="请输入 Markdown 内容..."
            class="markdown-input"
            @input="handleInput"
            @keydown="handleTextareaKeyDown"
          />
        </div>

        <!-- 预览 -->
        <div v-show="viewMode === 'preview' || viewMode === 'split'" class="preview-pane">
          <div class="markdown-preview" v-html="renderedHtml"></div>
        </div>
      </div>
    </div>

    <!-- 未选择文件 -->
    <el-empty 
      v-else
      description="请从左侧选择一个 Markdown 文件"
      :image-size="200"
    >
      <template #image>
        <el-icon :size="100" color="#909399">
          <FolderOpened />
        </el-icon>
      </template>
    </el-empty>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import {
  Document, 
  Edit, 
  View, 
  Connection, 
  DocumentChecked,
  FolderOpened,
  Download
} from '@element-plus/icons-vue'
import MarkdownIt from 'markdown-it'
import hljs from 'highlight.js'
import 'highlight.js/styles/github.css'

const props = defineProps({
  filePath: {
    type: String,
    default: ''
  },
  content: {
    type: String,
    default: ''
  },
  autoUpdate: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['save'])

const editContent = ref('')
const viewMode = ref('split') // edit, preview, split
const saving = ref(false)
const hasUnsavedChanges = ref(false)
const autoSaveEnabled = ref(false)
let autoSaveTimer = null
const AUTO_SAVE_INTERVAL = 5000 // 5 秒

// Markdown 渲染器
const md = new MarkdownIt({
  html: true,
  linkify: true,
  typographer: true,
  highlight: function (str, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return '<pre class="hljs"><code>' +
               hljs.highlight(str, { language: lang, ignoreIllegals: true }).value +
               '</code></pre>'
      } catch (__) {}
    }
    return '<pre class="hljs"><code>' + md.utils.escapeHtml(str) + '</code></pre>'
  }
})

// 计算属性
const fileName = computed(() => {
  if (!props.filePath) return ''
  const parts = props.filePath.split('/')
  return parts[parts.length - 1]
})

const renderedHtml = computed(() => {
  return md.render(editContent.value)
})

// 计算属性：是否应该自动保存
const shouldAutoSave = computed(() => {
  return props.autoUpdate && hasUnsavedChanges.value
})

// 重置自动保存计时器
const resetAutoSaveTimer = () => {
  if (autoSaveTimer) {
    clearTimeout(autoSaveTimer)
  }

  // 只有在应该自动保存时才设置自动保存计时器
  if (shouldAutoSave.value) {
    autoSaveTimer = setTimeout(() => {
      if (shouldAutoSave.value) {
        handleAutoSave()
      }
    }, AUTO_SAVE_INTERVAL)
  }
}

// 自动保存
const handleAutoSave = async () => {
  if (!shouldAutoSave.value) return

  try {
    await new Promise((resolve) => {
      emit('save', props.filePath, editContent.value)
      setTimeout(resolve, 300)
    })
    hasUnsavedChanges.value = false
    // 自动保存后，停止自动保存计时并恢复“已更新”状态
    autoSaveEnabled.value = false
    if (autoSaveTimer) {
      clearTimeout(autoSaveTimer)
      autoSaveTimer = null
    }
    ElMessage.success('已自动保存')
  } catch (error) {
    ElMessage.error('自动保存失败: ' + error.message)
  }
}

// 监听内容变化
watch(() => props.content, (newContent) => {
  // 文件重新加载时，设置内容且不触发“未保存”状态，不开启自动保存
  editContent.value = newContent
  hasUnsavedChanges.value = false
  autoSaveEnabled.value = false
  if (autoSaveTimer) {
    clearTimeout(autoSaveTimer)
    autoSaveTimer = null
  }
}, { immediate: true })

// 用户输入时才开启未保存与自动保存
const handleInput = () => {
  hasUnsavedChanges.value = true
  autoSaveEnabled.value = true
  resetAutoSaveTimer()
}

// 保存文件
const handleSave = async () => {
  if (!props.filePath) {
    ElMessage.warning('未选择文件')
    return
  }

  saving.value = true
  try {
    emit('save', props.filePath, editContent.value)
    hasUnsavedChanges.value = false
    autoSaveEnabled.value = false
    if (autoSaveTimer) {
      clearTimeout(autoSaveTimer)
      autoSaveTimer = null
    }
    ElMessage.success('保存成功')
  } finally {
    setTimeout(() => {
      saving.value = false
    }, 500)
  }
}

// 下载源文件
const handleDownload = () => {
  if (!props.filePath) {
    ElMessage.warning('未选择文件')
    return
  }

  // 文件大小检查 (10MB限制)
  const fileSize = new Blob([editContent.value]).size
  const maxSize = 10 * 1024 * 1024 // 10MB
  
  if (fileSize > maxSize) {
    ElMessage.warning(`文件过大 (${(fileSize / 1024 / 1024).toFixed(2)}MB)，建议分段下载`)
    return
  }

  try {
    // 创建Blob对象
    const blob = new Blob([editContent.value], { type: 'text/plain;charset=utf-8' })
    
    // 创建下载链接
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    
    // 从文件路径中提取文件名
    const fileName = props.filePath.split('/').pop() || 'download.md'
    link.download = fileName
    
    // 触发下载
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    
    // 清理URL对象
    window.URL.revokeObjectURL(url)
    
    ElMessage.success(`下载成功 (${(fileSize / 1024).toFixed(2)}KB)`)
  } catch (error) {
    console.error('下载失败:', error)
    ElMessage.error('下载失败: ' + (error.message || '未知错误'))
  }
}

// 处理快捷键
const handleKeyDown = (e) => {
  // Ctrl+S 或 Cmd+S 保存
  if ((e.ctrlKey || e.metaKey) && e.key === 's') {
    e.preventDefault() // 阻止浏览器默认保存行为
    if (props.filePath) {
      handleSave()
    }
  }
  // Ctrl+W 或 Cmd+W 关闭当前标签
  if ((e.ctrlKey || e.metaKey) && e.key === 'w') {
    e.preventDefault() // 阻止浏览器默认关闭行为
    emit('close-tab', props.filePath)
  }
}

// 处理textarea中的Tab键
const handleTextareaKeyDown = (e) => {
  if (e.key === 'Tab') {
    e.preventDefault() // 阻止默认Tab行为（切换焦点）
    
    const textarea = e.target
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const value = textarea.value
    
    // 插入2个空格作为缩进
    const newValue = value.substring(0, start) + '  ' + value.substring(end)
    
    editContent.value = newValue
    
    // 恢复光标位置
    nextTick(() => {
      textarea.selectionStart = textarea.selectionEnd = start + 2
    })
  } else {
    handleKeyDown(e)
  }
}

onMounted(() => {
  // 不再需要全局键盘监听
})

onBeforeUnmount(() => {
  if (autoSaveTimer) {
    clearTimeout(autoSaveTimer)
  }
})
</script>

<style lang="scss" scoped>
.markdown-editor {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.editor-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 20px;
  border-bottom: 1px solid #e4e7ed;
  background-color: #fafafa;

  .file-info {
    display: flex;
    align-items: center;
    gap: 8px;

    .file-name {
      font-size: 14px;
      font-weight: 500;
      color: #303133;
    }
  }

  .actions {
    display: flex;
    gap: 12px;
  }
}

.content-area {
  flex: 1;
  display: flex;
  overflow: hidden;

  &.mode-edit {
    .editor-pane {
      width: 100%;
    }
  }

  &.mode-preview {
    .preview-pane {
      width: 100%;
    }
  }

  &.mode-split {
    .editor-pane,
    .preview-pane {
      width: 50%;
    }
  }
}

.editor-pane,
.preview-pane {
  overflow-y: auto;
}

.editor-pane {
  border-right: 1px solid #e4e7ed;
  background-color: #ffffff;

  :deep(.markdown-input) {
    height: 100%;

    .el-textarea__inner {
      border: none;
      padding: 20px;
      font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
      font-size: 14px;
      line-height: 1.8;
      box-shadow: none;
      resize: none;
      height: 100% !important;
    }
  }
}

.preview-pane {
  background-color: #fff;
  padding: 20px;
}

.markdown-preview {
  max-width: 900px;
  margin: 0 auto;
  
  :deep(h1), :deep(h2), :deep(h3), :deep(h4), :deep(h5), :deep(h6) {
    margin-top: 24px;
    margin-bottom: 16px;
    font-weight: 600;
    line-height: 1.25;
    color: #303133;
  }

  :deep(h1) {
    font-size: 2em;
    border-bottom: 1px solid #e4e7ed;
    padding-bottom: 0.3em;
  }

  :deep(h2) {
    font-size: 1.5em;
    border-bottom: 1px solid #e4e7ed;
    padding-bottom: 0.3em;
  }

  :deep(h3) {
    font-size: 1.25em;
  }

  :deep(p) {
    margin-bottom: 16px;
    line-height: 1.8;
    color: #606266;
  }

  :deep(code) {
    background-color: #f5f7fa;
    padding: 2px 6px;
    border-radius: 3px;
    font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
    font-size: 0.9em;
    color: #e83e8c;
  }

  :deep(pre) {
    background-color: #f6f8fa;
    border-radius: 6px;
    padding: 16px;
    overflow-x: auto;
    margin-bottom: 16px;

    code {
      background-color: transparent;
      padding: 0;
      color: inherit;
      font-size: 0.875em;
    }
  }

  :deep(blockquote) {
    border-left: 4px solid #dfe2e5;
    padding-left: 16px;
    color: #6a737d;
    margin: 16px 0;
  }

  :deep(ul), :deep(ol) {
    padding-left: 2em;
    margin-bottom: 16px;

    li {
      margin-bottom: 8px;
      line-height: 1.8;
    }
  }

  :deep(table) {
    border-collapse: collapse;
    width: 100%;
    margin-bottom: 16px;

    th, td {
      border: 1px solid #dfe2e5;
      padding: 8px 12px;
      text-align: left;
    }

    th {
      background-color: #f6f8fa;
      font-weight: 600;
    }

    tr:nth-child(even) {
      background-color: #f6f8fa;
    }
  }

  :deep(a) {
    color: #409eff;
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }

  :deep(img) {
    max-width: 100%;
    height: auto;
    margin: 16px 0;
  }

  :deep(hr) {
    border: none;
    border-top: 1px solid #e4e7ed;
    margin: 24px 0;
  }
}
</style>
