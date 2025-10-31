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
            @refresh="refreshFileTree"
          />
        </div>
      </aside>

      <!-- 右侧编辑器区域 -->
      <main class="editor-panel">
        <!-- 多标签栏 -->
        <div v-if="openedTabs.length > 0" class="tabs-container">
          <el-tabs
            v-model="activeTab"
            type="card"
            closable
            @tab-remove="handleTabRemove"
            @tab-click="handleTabClick"
          >
            <el-tab-pane
              v-for="tab in openedTabs"
              :key="tab.path"
              :label="tab.name"
              :name="tab.path"
            >
              <template #label>
                <span 
                  class="tab-label" 
                  @contextmenu.prevent="handleTabContextMenu($event, tab)"
                >
                  <el-icon v-if="tab.isMarkdown" class="tab-icon">
                    <Document />
                  </el-icon>
                  <el-icon v-else class="tab-icon">
                    <Tickets />
                  </el-icon>
                  <span>{{ tab.name }}</span>
                  <el-switch
                    v-model="tab.autoUpdate"
                    size="small"
                    @change="handleAutoUpdateChange(tab)"
                    class="auto-update-switch"
                    :title="tab.autoUpdate ? '关闭自动更新' : '开启自动更新'"
                  />
                </span>
              </template>
            </el-tab-pane>
          </el-tabs>
        </div>
        
        <!-- 右键上下文菜单 -->
        <ul
          v-if="contextMenuVisible"
          class="tab-context-menu"
          :style="{ left: contextMenuX + 'px', top: contextMenuY + 'px' }"
          @click.stop
        >
          <li @click="closeCurrentTab">
            <el-icon><Close /></el-icon>
            关闭当前标签
          </li>
          <li @click="closeOtherTabs">
            <el-icon><Remove /></el-icon>
            关闭其他标签
          </li>
          <li @click="closeAllTabs">
            <el-icon><CloseBold /></el-icon>
            关闭所有标签
          </li>
          <li @click="closeLeftTabs">
            <el-icon><ArrowLeft /></el-icon>
            关闭左侧标签
          </li>
          <li @click="closeRightTabs">
            <el-icon><ArrowRight /></el-icon>
            关闭右侧标签
          </li>
        </ul>

        <!-- 编辑器内容 -->
        <div class="editor-content">
          <template v-if="activeTabData">
            <!-- Markdown编辑器 -->
            <MarkdownEditor
              v-if="activeTabData.isMarkdown"
              :key="activeTabData.path"
              :file-path="activeTabData.path"
              :content="activeTabData.content"
              :auto-update="activeTabData.autoUpdate"
              @save="handleFileSave"
              @close-tab="handleTabRemove"
            />
            <CodeEditor
              v-else
              :key="activeTabData.path"
              :file-path="activeTabData.path"
              :content="activeTabData.content"
              :auto-update="activeTabData.autoUpdate"
              @save="handleFileSave"
              @close-tab="handleTabRemove"
            />
          </template>
          <el-empty
            v-else
            description="请从左侧文件树选择文件"
            :image-size="200"
          >
            <template #image>
              <el-icon :size="100" color="#909399">
                <FolderOpened />
              </el-icon>
            </template>
          </el-empty>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Document, Refresh, Tickets, FolderOpened, Close, Remove, CloseBold, ArrowLeft, ArrowRight } from '@element-plus/icons-vue'
import FileTree from './components/FileTree.vue'
import MarkdownEditor from './components/MarkdownEditor.vue'
import CodeEditor from './components/CodeEditor.vue'
import { getFileTree, getFileContent, saveFileContent } from './api/files'

// UI配置常量
const UI_CONFIG = {
  CONTEXT_MENU: {
    MIN_WIDTH: 133,
    PADDING: 6
  },
  ANIMATION: {
    DURATION: 2000,
    DEBOUNCE_DELAY: 300
  },
  FILE: {
    MAX_DOWNLOAD_SIZE: 10 * 1024 * 1024 // 10MB
  }
}

const fileTree = ref([])
const loading = ref(false)

// 多标签页管理
const openedTabs = ref([])
const activeTab = ref('')

// 编辑器类型切换 (original: 原版, bytemd: ByteMD演示版, vditor: Vditor演示版, milkdown: Milkdown演示版)

// 右键菜单状态
const contextMenuVisible = ref(false)
const contextMenuX = ref(0)
const contextMenuY = ref(0)
const contextMenuTab = ref(null)

// localStorage 键名
const STORAGE_KEYS = {
  OPENED_TABS: 'markdown_editor_opened_tabs',
  ACTIVE_TAB: 'markdown_editor_active_tab'
}

// 当前激活标签的数据
const activeTabData = computed(() => {
  return openedTabs.value.find(tab => tab.path === activeTab.value)
})

// 防抖函数
const debounce = (func, delay) => {
  let timeoutId
  return function (...args) {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(() => func.apply(this, args), delay)
  }
}

// 保存标签页状态到 localStorage
const saveTabsState = debounce(() => {
  try {
    const tabsData = openedTabs.value.map(tab => ({
      path: tab.path,
      name: tab.name,
      isMarkdown: tab.isMarkdown,
      autoUpdate: tab.autoUpdate  // 保存自动更新状态
      // 不保存 content，避免占用过多存储空间
    }))
    localStorage.setItem(STORAGE_KEYS.OPENED_TABS, JSON.stringify(tabsData))
    if (activeTab.value) {
      localStorage.setItem(STORAGE_KEYS.ACTIVE_TAB, activeTab.value)
    }
  } catch (error) {
    console.warn('保存标签页状态失败:', error)
  }
}, UI_CONFIG.ANIMATION.DEBOUNCE_DELAY)

// 从 localStorage 恢复标签页状态
const restoreTabsState = async () => {
  try {
    const savedTabs = localStorage.getItem(STORAGE_KEYS.OPENED_TABS)
    const savedActiveTab = localStorage.getItem(STORAGE_KEYS.ACTIVE_TAB)
    
    if (savedTabs) {
      const tabsData = JSON.parse(savedTabs)
      const restoredTabs = []
      
      // 重新加载每个标签页的内容
      for (const tabData of tabsData) {
        try {
          const content = await getFileContent(tabData.path)
          restoredTabs.push({
            ...tabData,
            content: content,
            autoUpdate: tabData.autoUpdate !== undefined ? tabData.autoUpdate : true  // 确保autoUpdate属性存在
          })
        } catch (error) {
          console.warn(`恢复标签页 ${tabData.path} 失败:`, error)
          // 如果文件不存在，跳过该标签页
        }
      }
      
      openedTabs.value = restoredTabs
      
      // 恢复激活的标签页
      if (savedActiveTab && restoredTabs.find(tab => tab.path === savedActiveTab)) {
        activeTab.value = savedActiveTab
      } else if (restoredTabs.length > 0) {
        activeTab.value = restoredTabs[0].path
      }
    }
  } catch (error) {
    console.warn('恢复标签页状态失败:', error)
  }
}

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

// 处理文件选择 - 打开新标签或切换到已存在的标签
const handleFileSelect = async (filePath) => {
  if (!filePath) return
  
  // 检查文件是否已经打开
  const existingTab = openedTabs.value.find(tab => tab.path === filePath)
  if (existingTab) {
    // 已打开，直接切换到该标签
    activeTab.value = filePath
    saveTabsState()
    return
  }
  
  try {
    // 读取文件内容
    const content = await getFileContent(filePath)
    
    // 提取文件名
    const fileName = filePath.split('/').pop()
    
    // 判断文件类型
    const isMarkdown = filePath.toLowerCase().endsWith('.md')
    
    // 创建新标签
    const newTab = {
      path: filePath,
      name: fileName,
      content: content,
      isMarkdown: isMarkdown,
      autoUpdate: true  // 默认开启自动更新
    }
    
    // 添加到打开的标签列表
    openedTabs.value.push(newTab)
    
    // 激活新标签
    activeTab.value = filePath
    
    // 保存状态
    saveTabsState()
    
  } catch (error) {
    ElMessage.error('打开文件失败: ' + error.message)
  }
}

// 处理标签点击
const handleTabClick = (tab) => {
  activeTab.value = tab.props.name
  saveTabsState()
}

// 处理标签关闭
const handleTabRemove = (targetPath) => {
  const tabs = openedTabs.value
  const targetIndex = tabs.findIndex(tab => tab.path === targetPath)
  
  if (targetIndex === -1) return
  
  // 如果关闭的是当前激活的标签，需要切换到其他标签
  if (activeTab.value === targetPath) {
    // 优先切换到右边的标签，如果没有则切换到左边的
    if (targetIndex < tabs.length - 1) {
      activeTab.value = tabs[targetIndex + 1].path
    } else if (targetIndex > 0) {
      activeTab.value = tabs[targetIndex - 1].path
    } else {
      activeTab.value = ''
    }
  }
  
  // 移除标签
  openedTabs.value.splice(targetIndex, 1)
  
  // 保存状态
  saveTabsState()
}

// 处理文件保存
const handleFileSave = async (filePath, content) => {
  try {
    await saveFileContent(filePath, content)
    
    // 更新标签中的内容
    const tab = openedTabs.value.find(t => t.path === filePath)
    if (tab) {
      tab.content = content
    }
    
    // 成功提示由子组件负责，避免重复 toast
  } catch (error) {
    ElMessage.error('保存失败: ' + error.message)
  }
}

// 处理自动更新开关变化
const handleAutoUpdateChange = (tab) => {
  saveTabsState()
  
  ElMessage({
    message: tab.autoUpdate ? '已开启自动更新' : '已关闭自动更新',
    type: 'info',
    duration: UI_CONFIG.ANIMATION.DURATION
  })
}

// 获取编辑器描述

// 右键菜单处理方法
const handleTabContextMenu = (event, tab) => {
  event.preventDefault()
  contextMenuTab.value = tab
  contextMenuX.value = event.clientX
  contextMenuY.value = event.clientY
  contextMenuVisible.value = true
  
  // 点击其他地方关闭菜单
  document.addEventListener('click', hideContextMenu)
}

const hideContextMenu = () => {
  contextMenuVisible.value = false
  document.removeEventListener('click', hideContextMenu)
}

// 关闭当前标签
const closeCurrentTab = () => {
  if (contextMenuTab.value) {
    handleTabRemove(contextMenuTab.value.path)
    hideContextMenu()
  }
}

// 关闭其他标签
const closeOtherTabs = () => {
  if (contextMenuTab.value) {
    const targetPath = contextMenuTab.value.path
    openedTabs.value = openedTabs.value.filter(tab => tab.path === targetPath)
    activeTab.value = targetPath
    saveTabsState()
    hideContextMenu()
  }
}

// 关闭所有标签
const closeAllTabs = () => {
  openedTabs.value = []
  activeTab.value = ''
  saveTabsState()
  hideContextMenu()
}

// 关闭左侧标签
const closeLeftTabs = () => {
  if (contextMenuTab.value) {
    const targetIndex = openedTabs.value.findIndex(tab => tab.path === contextMenuTab.value.path)
    if (targetIndex > 0) {
      openedTabs.value = openedTabs.value.slice(targetIndex)
      saveTabsState()
    }
    hideContextMenu()
  }
}

// 关闭右侧标签
const closeRightTabs = () => {
  if (contextMenuTab.value) {
    const targetIndex = openedTabs.value.findIndex(tab => tab.path === contextMenuTab.value.path)
    if (targetIndex < openedTabs.value.length - 1) {
      openedTabs.value = openedTabs.value.slice(0, targetIndex + 1)
      saveTabsState()
    }
    hideContextMenu()
  }
}

onMounted(async () => {
  // 先恢复标签页状态
  await restoreTabsState()
  // 再加载文件树
  await loadFileTree()
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
  display: flex;
  flex-direction: column;

  .tabs-container {
    background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
    border-bottom: 1px solid #e4e7ed;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);

    :deep(.el-tabs) {
      .el-tabs__header {
        margin: 0;
        border-bottom: none;
        background: transparent;
      }

      .el-tabs__nav {
        border: none;
        padding: 8px 12px 0;
      }

      .el-tabs__item {
        height: 40px;
        line-height: 40px;
        padding: 0 20px;
        border: 1px solid transparent;
        border-bottom: none;
        border-radius: 8px 8px 0 0;
        margin-right: 4px;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        background: transparent;
        color: #606266;
        font-size: 14px;

        &:hover {
          background: rgba(102, 126, 234, 0.05);
          color: #667eea;
        }

        &.is-active {
          background: white;
          border-color: #e4e7ed;
          border-bottom-color: white;
          color: #667eea;
          font-weight: 500;
          box-shadow: 0 -2px 8px rgba(102, 126, 234, 0.1);
        }

        .el-icon.is-icon-close {
          width: 16px;
          height: 16px;
          transition: all 0.3s;

          &:hover {
            background-color: rgba(245, 108, 108, 0.1);
            color: #f56c6c;
            border-radius: 50%;
          }
        }
      }

      .el-tabs__nav-wrap::after {
        display: none;
      }
    }

    .tab-label {
      display: flex;
      align-items: center;
      gap: 6px;

      .tab-icon {
        font-size: 16px;
      }

      .auto-update-switch {
        margin-left: 4px;
        
        :deep(.el-switch__core) {
          min-width: 28px;
          height: 14px;
          border-radius: 7px;
        }
        
        :deep(.el-switch__core::after) {
          width: 10px;
          height: 10px;
          top: 2px;
          left: 2px;
        }
        
        &.is-checked :deep(.el-switch__core::after) {
          left: calc(100% - 12px);
        }
        
        :deep(.el-switch__action) {
          width: 10px;
          height: 10px;
        }
      }
    }
  }

  .editor-content {
    flex: 1;
    overflow: hidden;
    position: relative;
    display: flex;
    flex-direction: column;
  }
}

// 右键上下文菜单样式
.tab-context-menu {
  position: fixed;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.7) 0%, rgba(118, 75, 162, 0.7) 100%);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 12px;
  box-shadow: 
    0 8px 16px rgba(0, 0, 0, 0.15),
    0 4px 8px rgba(0, 0, 0, 0.1),
    inset 0 1px 0 rgba(255, 255, 255, 0.15);
  z-index: 1000;
  padding: v-bind('UI_CONFIG.CONTEXT_MENU.PADDING + "px"');
  min-width: v-bind('UI_CONFIG.CONTEXT_MENU.MIN_WIDTH + "px"');
  list-style: none;
  margin: 0;
  font-size: 12px;
  backdrop-filter: blur(16px);
  
  li {
    padding: 8px 12px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    color: rgba(255, 255, 255, 0.85);
    border-radius: 8px;
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    font-weight: 400;
    background: rgba(255, 255, 255, 0.08);
    margin-bottom: 2px;
    border: 1px solid rgba(255, 255, 255, 0.08);
    
    &:last-child {
      margin-bottom: 0;
    }
    
    &:hover {
      background: rgba(255, 255, 255, 0.18);
      color: rgba(255, 255, 255, 0.95);
      transform: translateY(-1px) scale(1.01);
      box-shadow: 
        0 4px 8px rgba(0, 0, 0, 0.12),
        inset 0 1px 0 rgba(255, 255, 255, 0.2);
      border-color: rgba(255, 255, 255, 0.15);
    }
    
    &:active {
      background: rgba(255, 255, 255, 0.25);
      transform: translateY(0) scale(0.99);
    }
    
    .el-icon {
      font-size: 14px;
      opacity: 0.8;
      filter: drop-shadow(0 1px 1px rgba(0, 0, 0, 0.1));
    }
    
    &:hover .el-icon {
      opacity: 0.95;
      filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.15));
    }
  }
}
</style>
