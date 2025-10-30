<template>
  <div class="code-editor">
    <div v-if="filePath" class="editor-container">
      <!-- 工具栏 -->
      <div class="toolbar">
        <div class="file-info">
          <el-icon :size="18">
            <Document />
          </el-icon>
          <span class="file-name">{{ fileName }}</span>
          <el-tag type="info" size="small">{{ fileLanguage }}</el-tag>
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
          <el-button 
            type="success" 
            :icon="DocumentChecked"
            @click="handleSave"
            :loading="saving"
          >
            保存
          </el-button>
        </div>
      </div>

      <!-- 编辑区域 -->
      <div class="content-area">
        <div ref="editorContainer" class="monaco-editor-container"></div>
      </div>
    </div>

    <!-- 未选择文件 -->
    <el-empty 
      v-else
      description="请从左侧选择一个代码文件"
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
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue'
import { ElMessage } from 'element-plus'
import { 
  Document, 
  DocumentChecked,
  FolderOpened 
} from '@element-plus/icons-vue'
import loader from '@monaco-editor/loader'

const props = defineProps({
  filePath: {
    type: String,
    default: ''
  },
  content: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['save'])

const editorContainer = ref(null)
let editor = null
let monaco = null
const saving = ref(false)
const hasUnsavedChanges = ref(false)
const autoSaveEnabled = ref(false)
let autoSaveTimer = null
let isProgrammaticChange = false
const AUTO_SAVE_INTERVAL = 5000 // 5 秒

// 获取文件名
const fileName = computed(() => {
  if (!props.filePath) return ''
  const parts = props.filePath.split('/')
  return parts[parts.length - 1]
})

// 获取文件语言类型和 Monaco 语言标识
const fileLanguage = computed(() => {
  if (!props.filePath) return ''
  const name = props.filePath.toLowerCase()
  
  if (name.endsWith('.py')) return 'Python'
  if (name.endsWith('.js')) return 'JavaScript'
  if (name.endsWith('.jsx')) return 'JSX'
  if (name.endsWith('.ts')) return 'TypeScript'
  if (name.endsWith('.tsx')) return 'TSX'
  if (name.endsWith('.vue')) return 'Vue'
  if (name.endsWith('.java')) return 'Java'
  if (name.endsWith('.cpp') || name.endsWith('.cc')) return 'C++'
  if (name.endsWith('.c')) return 'C'
  if (name.endsWith('.h')) return 'C Header'
  if (name.endsWith('.go')) return 'Go'
  if (name.endsWith('.rs')) return 'Rust'
  if (name.endsWith('.rb')) return 'Ruby'
  if (name.endsWith('.php')) return 'PHP'
  if (name.endsWith('.sh') || name.endsWith('.bash')) return 'Bash'
  if (name.endsWith('.zsh')) return 'Zsh'
  if (name.endsWith('.fish')) return 'Fish'
  if (name.endsWith('.json')) return 'JSON'
  if (name.endsWith('.yaml') || name.endsWith('.yml')) return 'YAML'
  if (name.endsWith('.xml')) return 'XML'
  if (name.endsWith('.html')) return 'HTML'
  if (name.endsWith('.css')) return 'CSS'
  if (name.endsWith('.scss')) return 'SCSS'
  if (name.endsWith('.less')) return 'LESS'
  if (name.endsWith('.sql')) return 'SQL'
  if (name.endsWith('.md')) return 'Markdown'
  if (name.endsWith('.txt')) return 'Text'
  
  return 'Code'
})

// 获取 Monaco 编辑器的语言标识
const getMonacoLanguage = (filePath) => {
  const name = filePath.toLowerCase()
  
  if (name.endsWith('.py')) return 'python'
  if (name.endsWith('.js')) return 'javascript'
  if (name.endsWith('.jsx')) return 'javascript'
  if (name.endsWith('.ts')) return 'typescript'
  if (name.endsWith('.tsx')) return 'typescript'
  if (name.endsWith('.vue')) return 'html'
  if (name.endsWith('.java')) return 'java'
  if (name.endsWith('.cpp') || name.endsWith('.cc')) return 'cpp'
  if (name.endsWith('.c')) return 'c'
  if (name.endsWith('.h')) return 'c'
  if (name.endsWith('.go')) return 'go'
  if (name.endsWith('.rs')) return 'rust'
  if (name.endsWith('.rb')) return 'ruby'
  if (name.endsWith('.php')) return 'php'
  if (name.endsWith('.sh') || name.endsWith('.bash')) return 'shell'
  if (name.endsWith('.zsh')) return 'shell'
  if (name.endsWith('.fish')) return 'shell'
  if (name.endsWith('.json')) return 'json'
  if (name.endsWith('.yaml') || name.endsWith('.yml')) return 'yaml'
  if (name.endsWith('.xml')) return 'xml'
  if (name.endsWith('.html')) return 'html'
  if (name.endsWith('.css')) return 'css'
  if (name.endsWith('.scss')) return 'scss'
  if (name.endsWith('.less')) return 'less'
  if (name.endsWith('.sql')) return 'sql'
  if (name.endsWith('.md')) return 'markdown'
  if (name.endsWith('.txt')) return 'plaintext'
  
  return 'plaintext'
}

// 初始化编辑器
const initEditor = async () => {
  if (!editorContainer.value) return
  
  if (editor) {
    editor.dispose()
  }

  try {
    // 加载 Monaco Editor
    if (!monaco) {
      monaco = await loader.init()
    }

    const language = getMonacoLanguage(props.filePath)
    
    editor = monaco.editor.create(editorContainer.value, {
      value: props.content,
      language: language,
      theme: 'vs-light',
      fontSize: 13,
      fontFamily: "'Monaco', 'Menlo', 'Ubuntu Mono', 'Courier New', monospace",
      lineNumbers: 'on',
      scrollBeyondLastLine: false,
      minimap: { enabled: true },
      wordWrap: 'on',
      automaticLayout: true,
      tabSize: 2,
      insertSpaces: true,
      formatOnPaste: true,
      formatOnType: true,
    })

    // 监听编辑器内容变化（仅响应用户输入）
    editor.onDidChangeModelContent(() => {
      if (isProgrammaticChange) return
      hasUnsavedChanges.value = true
      autoSaveEnabled.value = true
      resetAutoSaveTimer()
    })

    // 初始化为“已更新”，不启动自动保存
    hasUnsavedChanges.value = false
    autoSaveEnabled.value = false
  } catch (error) {
    ElMessage.error('Monaco Editor 加载失败: ' + error.message)
  }
}

// 重置自动保存计时器
const resetAutoSaveTimer = () => {
  if (autoSaveTimer) {
    clearTimeout(autoSaveTimer)
  }

  autoSaveTimer = setTimeout(() => {
    if (hasUnsavedChanges.value && editor) {
      handleAutoSave()
    }
  }, AUTO_SAVE_INTERVAL)
}

// 自动保存
const handleAutoSave = async () => {
  if (!editor || !hasUnsavedChanges.value) return

  try {
    const content = editor.getValue()
    await new Promise((resolve) => {
      emit('save', props.filePath, content)
      setTimeout(resolve, 300)
    })
    hasUnsavedChanges.value = false
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

// 手动保存文件
const handleSave = async () => {
  if (!props.filePath) {
    ElMessage.warning('未选择文件')
    return
  }

  if (!editor) return

  saving.value = true
  try {
    const content = editor.getValue()
    emit('save', props.filePath, content)
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

// 监听文件路径变化
watch(() => props.filePath, () => {
  if (props.filePath) {
    initEditor()
  }
}, { immediate: false })

// 监听内容变化（外部更新）
watch(() => props.content, (newContent) => {
  if (editor && newContent !== editor.getValue()) {
    isProgrammaticChange = true
    editor.setValue(newContent)
    isProgrammaticChange = false
    hasUnsavedChanges.value = false
    autoSaveEnabled.value = false
    if (autoSaveTimer) {
      clearTimeout(autoSaveTimer)
      autoSaveTimer = null
    }
  }
}, { immediate: false })

// 处理快捷键
const handleKeyDown = (e) => {
  // Ctrl+S 或 Cmd+S 保存
  if ((e.ctrlKey || e.metaKey) && e.key === 's') {
    e.preventDefault() // 阻止浏览器默认保存行为
    if (props.filePath && editor) {
      handleSave()
    }
  }
}

onMounted(() => {
  if (props.filePath) {
    initEditor()
  }
  // 监听键盘事件
  document.addEventListener('keydown', handleKeyDown)
})

onBeforeUnmount(() => {
  if (autoSaveTimer) {
    clearTimeout(autoSaveTimer)
  }
  if (editor) {
    editor.dispose()
  }
  // 移除键盘事件监听
  document.removeEventListener('keydown', handleKeyDown)
})
</script>

<style lang="scss" scoped>
.code-editor {
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
}

.monaco-editor-container {
  width: 100%;
  height: 100%;
}
</style>
