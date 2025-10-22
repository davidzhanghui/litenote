<template>
  <div class="app-container">
    <!-- 顶部栏 -->
    <header class="app-header">
      <div class="header-content">
        <div class="logo-section">
          <el-icon :size="32" color="#409EFF">
            <Document />
          </el-icon>
          <h1>Markdown 文档管理系统</h1>
        </div>
        <div class="welcome-section">
          <span>欢迎使用</span>
          <el-tag type="success" effect="dark">Vue3 + Element Plus</el-tag>
        </div>
      </div>
    </header>

    <!-- 主内容区域 -->
    <div class="app-main">
      <!-- 左侧文件树 -->
      <aside class="file-tree-panel">
        <div class="panel-header">
          <h3>文件目录</h3>
          <el-button 
            type="primary" 
            :icon="Refresh" 
            circle 
            size="small"
            @click="refreshFileTree"
            :loading="loading"
          />
        </div>
        <div class="tree-container">
          <FileTree 
            :tree-data="fileTree"
            :loading="loading"
            @select="handleFileSelect"
          />
        </div>
      </aside>

      <!-- 右侧编辑器 -->
      <main class="editor-panel">
        <MarkdownEditor
          :file-path="currentFilePath"
          :content="currentFileContent"
          @save="handleFileSave"
        />
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Document, Refresh } from '@element-plus/icons-vue'
import FileTree from './components/FileTree.vue'
import MarkdownEditor from './components/MarkdownEditor.vue'
import { getFileTree, getFileContent, saveFileContent } from './api/files'

const fileTree = ref([])
const loading = ref(false)
const currentFilePath = ref('')
const currentFileContent = ref('')

// 加载文件树
const loadFileTree = async () => {
  loading.value = true
  try {
    const data = await getFileTree()
    fileTree.value = data
  } catch (error) {
    ElMessage.error('加载文件树失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

// 刷新文件树
const refreshFileTree = () => {
  loadFileTree()
}

// 处理文件选择
const handleFileSelect = async (filePath) => {
  if (!filePath) return
  
  try {
    currentFilePath.value = filePath
    const content = await getFileContent(filePath)
    currentFileContent.value = content
  } catch (error) {
    ElMessage.error('读取文件失败: ' + error.message)
  }
}

// 处理文件保存
const handleFileSave = async (filePath, content) => {
  try {
    await saveFileContent(filePath, content)
    ElMessage.success('保存成功')
  } catch (error) {
    ElMessage.error('保存失败: ' + error.message)
  }
}

onMounted(() => {
  loadFileTree()
})
</script>

<style lang="scss" scoped>
.app-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: #f5f7fa;
}

.app-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  z-index: 100;

  .header-content {
    height: 64px;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .logo-section {
    display: flex;
    align-items: center;
    gap: 12px;

    h1 {
      margin: 0;
      font-size: 20px;
      font-weight: 600;
    }
  }

  .welcome-section {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 14px;
  }
}

.app-main {
  flex: 1;
  display: flex;
  overflow: hidden;
  gap: 1px;
  background-color: #e4e7ed;
}

.file-tree-panel {
  width: 320px;
  background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
  display: flex;
  flex-direction: column;
  box-shadow: 2px 0 16px rgba(0, 0, 0, 0.08);
  position: relative;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 3px;
    background: linear-gradient(90deg, 
      #667eea 0%, 
      #764ba2 25%, 
      #f093fb 50%, 
      #4facfe 75%, 
      #00f2fe 100%
    );
  }

  .panel-header {
    padding: 20px;
    background: linear-gradient(135deg, #667eea15 0%, #764ba215 100%);
    border-bottom: 2px solid transparent;
    border-image: linear-gradient(90deg, #667eea, #764ba2) 1;
    display: flex;
    align-items: center;
    justify-content: space-between;

    h3 {
      margin: 0;
      font-size: 16px;
      font-weight: 700;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      display: flex;
      align-items: center;
      gap: 8px;

      &::before {
        content: '📁';
        font-size: 20px;
        -webkit-text-fill-color: initial;
      }
    }

    :deep(.el-button) {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border: none;
      color: white;
      transition: all 0.3s;

      &:hover {
        transform: rotate(180deg) scale(1.1);
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
      }
    }
  }

  .tree-container {
    flex: 1;
    overflow-y: auto;
    padding: 12px 0;
    
    &::-webkit-scrollbar {
      width: 6px;
    }
    
    &::-webkit-scrollbar-track {
      background: #f1f5f9;
      border-radius: 3px;
    }
    
    &::-webkit-scrollbar-thumb {
      background: linear-gradient(180deg, #667eea 0%, #764ba2 100%);
      border-radius: 3px;
      
      &:hover {
        background: linear-gradient(180deg, #764ba2 0%, #667eea 100%);
      }
    }
  }
}

.editor-panel {
  flex: 1;
  background-color: white;
  overflow: hidden;
}
</style>
