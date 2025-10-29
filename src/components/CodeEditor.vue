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
        <el-input
          v-model="editContent"
          type="textarea"
          :autosize="{ minRows: 20 }"
          placeholder="请输入代码内容..."
          class="code-input"
        />
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
import { ref, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { 
  Document, 
  DocumentChecked,
  FolderOpened 
} from '@element-plus/icons-vue'

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

const editContent = ref('')
const saving = ref(false)

// 获取文件名
const fileName = computed(() => {
  if (!props.filePath) return ''
  const parts = props.filePath.split('/')
  return parts[parts.length - 1]
})

// 获取文件语言类型
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

// 监听内容变化
watch(() => props.content, (newContent) => {
  editContent.value = newContent
}, { immediate: true })

// 保存文件
const handleSave = async () => {
  if (!props.filePath) {
    ElMessage.warning('未选择文件')
    return
  }

  saving.value = true
  try {
    emit('save', props.filePath, editContent.value)
  } finally {
    setTimeout(() => {
      saving.value = false
    }, 500)
  }
}
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

.code-input {
  height: 100%;

  :deep(.el-textarea__inner) {
    border: none;
    padding: 20px;
    font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', 'Courier New', monospace;
    font-size: 13px;
    line-height: 1.6;
    box-shadow: none;
    resize: none;
    height: 100% !important;
    background-color: #f8f9fa;
    color: #2c3e50;
    
    &:focus {
      background-color: #ffffff;
    }
  }
}
</style>
