<template>
  <div class="file-tree">
    <el-tree
      v-if="!loading && treeData.length > 0"
      ref="treeRef"
      :data="treeData"
      :props="treeProps"
      node-key="path"
      highlight-current
      :expand-on-click-node="false"
      default-expand-all
      @node-click="handleNodeClick"
      @node-contextmenu="handleContextMenu"
    >
      <template #default="{ node, data }">
        <span 
          class="tree-node" 
          :class="{ 'is-directory': data.type === 'directory', 'is-file': data.type === 'file' }"
          @mouseenter="handleNodeHover(data, $event)"
          @mouseleave="handleNodeLeave"
        >
          <el-icon :size="18" :class="getIconClass(data)">
            <FolderOpened v-if="data.type === 'directory' && node.expanded" />
            <Folder v-else-if="data.type === 'directory'" />
            <Document v-else />
          </el-icon>
          <span class="node-label" :class="getLabelClass(data)">{{ node.label }}</span>
          
          <!-- 悬浮操作按钮 -->
          <div 
            v-if="hoverNodePath === data.path"
            class="node-actions"
            @click.stop
          >
            <el-button 
              v-if="data.type === 'directory'"
              :icon="FolderAdd" 
              size="small" 
              text
              @click="handleCreateDirectoryFromHover(data)"
              title="新建目录"
            />
            <el-button 
              v-if="data.type === 'directory'"
              :icon="Plus" 
              size="small" 
              text
              @click="handleCreateFileFromHover(data)"
              title="新建文件"
            />
            <el-button 
              :icon="Edit" 
              size="small" 
              text
              @click="data.type === 'directory' ? handleRenameDirectoryFromHover(data) : handleRenameFileFromHover(data)"
              title="重命名"
            />
            <el-button 
              :icon="Delete" 
              size="small" 
              text
              type="danger"
              @click="data.type === 'directory' ? handleDeleteDirectoryFromHover(data) : handleDeleteFileFromHover(data)"
              title="删除"
            />
          </div>
        </span>
      </template>
    </el-tree>

    <el-empty 
      v-else-if="!loading && treeData.length === 0"
      description="暂无文件"
      :image-size="100"
    />

    <div v-else class="loading-container">
      <el-icon class="is-loading" :size="32">
        <Loading />
      </el-icon>
      <p>加载中...</p>
    </div>

    <!-- 右键菜单 -->
    <div 
      v-if="contextMenuVisible"
      class="context-menu"
      :style="{ top: contextMenuY + 'px', left: contextMenuX + 'px' }"
      @click.stop
    >
      <!-- 文件夹菜单 -->
      <template v-if="contextMenuData?.type === 'directory'">
        <div class="context-menu-item" @click="handleCreateDirectory">
          <el-icon><Plus /></el-icon>
          <span>创建目录</span>
        </div>
        <div class="context-menu-item" @click="handleCreateFile">
          <el-icon><Plus /></el-icon>
          <span>新建文件</span>
        </div>
        <div class="context-menu-item" @click="handleRenameDirectory">
          <el-icon><Edit /></el-icon>
          <span>重命名</span>
        </div>
        <div class="context-menu-divider" />
        <div class="context-menu-item delete-item" @click="handleDeleteDirectory">
          <el-icon><Delete /></el-icon>
          <span>删除</span>
        </div>
      </template>
      
      <!-- 文件菜单 -->
      <template v-if="contextMenuData?.type === 'file'">
        <div class="context-menu-item" @click="handleRenameFile">
          <el-icon><Edit /></el-icon>
          <span>重命名</span>
        </div>
        <div class="context-menu-divider" />
        <div class="context-menu-item delete-item" @click="handleDeleteFile">
          <el-icon><Delete /></el-icon>
          <span>删除</span>
        </div>
      </template>
    </div>

    <!-- 创建目录对话框 -->
    <el-dialog v-model="createDirDialogVisible" title="创建目录" width="400px" @opened="focusCreateDirInput">
      <el-input 
        ref="createDirInputRef"
        v-model="newDirName" 
        placeholder="请输入目录名称"
        @keyup.enter="confirmCreateDirectory"
      />
      <template #footer>
        <el-button @click="createDirDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmCreateDirectory">创建</el-button>
      </template>
    </el-dialog>

    <!-- 创建文件对话框 -->
    <el-dialog v-model="createFileDialogVisible" title="新建文件" width="400px" @opened="focusCreateFileInput">
      <div class="create-file-form">
        <div class="form-group">
          <label>文件名:</label>
          <el-input 
            ref="createFileInputRef"
            v-model="newFileName" 
            placeholder="请输入文件名（不含扩展名）"
            @keyup.enter="confirmCreateFile"
          />
        </div>
        <div class="form-group">
          <label>文件类型:</label>
          <el-select 
            v-model="newFileExtension" 
            placeholder="选择文件类型"
            filterable
          >
            <el-option-group 
              v-for="group in extensionGroups" 
              :key="group.label" 
              :label="group.label"
            >
              <el-option 
                v-for="ext in group.options" 
                :key="ext.value" 
                :label="ext.label" 
                :value="ext.value"
              />
            </el-option-group>
          </el-select>
        </div>
      </div>
      <template #footer>
        <el-button @click="createFileDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmCreateFile">创建</el-button>
      </template>
    </el-dialog>

    <!-- 重命名目录对话框 -->
    <el-dialog v-model="renameDirDialogVisible" title="重命名目录" width="400px" @opened="focusRenameDirInput">
      <el-input 
        ref="renameDirInputRef"
        v-model="renameDirName" 
        placeholder="请输入新的目录名称"
        @keyup.enter="confirmRenameDirectory"
      />
      <template #footer>
        <el-button @click="renameDirDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmRenameDirectory">确认</el-button>
      </template>
    </el-dialog>

    <!-- 重命名文件对话框 -->
    <el-dialog v-model="renameFileDialogVisible" title="重命名文件" width="400px" @opened="focusRenameFileInput">
      <el-input 
        ref="renameFileInputRef"
        v-model="renameFileName" 
        placeholder="请输入新的文件名（包含扩展名）"
        @keyup.enter="confirmRenameFile"
      />
      <template #footer>
        <el-button @click="renameFileDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmRenameFile">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Folder, 
  FolderOpened,
  FolderAdd,
  Document, 
  Loading,
  Plus,
  Edit,
  Delete
} from '@element-plus/icons-vue'
import { 
  createDirectory, 
  renameDirectory, 
  createFile,
  deleteDirectory,
  deleteFile,
  renameFile,
  getSupportedExtensions 
} from '../api/files'

const props = defineProps({
  treeData: {
    type: Array,
    default: () => []
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['select', 'refresh'])

const treeRef = ref(null)
const dropdownRef = ref(null)
const contextMenuVisible = ref(false)
const contextMenuData = ref(null)
const contextMenuX = ref(0)
const contextMenuY = ref(0)

// 创建目录相关
const createDirDialogVisible = ref(false)
const newDirName = ref('')
const selectedDirPath = ref('')

// 创建文件相关
const createFileDialogVisible = ref(false)
const newFileName = ref('')
const newFileExtension = ref('')
const supportedExtensions = ref([])

// 重命名目录相关
const renameDirDialogVisible = ref(false)
const renameDirName = ref('')
const renameDirPath = ref('')

// 重命名文件相关
const renameFileDialogVisible = ref(false)
const renameFileName = ref('')
const renameFilePath = ref('')

// 悬浮状态
const hoverNodePath = ref('')

// 输入框 ref
const createDirInputRef = ref(null)
const createFileInputRef = ref(null)
const renameDirInputRef = ref(null)
const renameFileInputRef = ref(null)

const treeProps = {
  children: 'children',
  label: 'name'
}

// 分组的文件扩展名
const extensionGroups = computed(() => {
  return [
    {
      label: 'Markdown & Text',
      options: [
        { label: 'Markdown (.md)', value: '.md' },
        { label: 'Text (.txt)', value: '.txt' }
      ]
    },
    {
      label: 'Web 开发',
      options: [
        { label: 'HTML (.html)', value: '.html' },
        { label: 'CSS (.css)', value: '.css' },
        { label: 'SCSS (.scss)', value: '.scss' },
        { label: 'LESS (.less)', value: '.less' },
        { label: 'JavaScript (.js)', value: '.js' },
        { label: 'JSX (.jsx)', value: '.jsx' },
        { label: 'TypeScript (.ts)', value: '.ts' },
        { label: 'TSX (.tsx)', value: '.tsx' },
        { label: 'Vue (.vue)', value: '.vue' },
        { label: 'XML (.xml)', value: '.xml' }
      ]
    },
    {
      label: '编程语言',
      options: [
        { label: 'Python (.py)', value: '.py' },
        { label: 'Java (.java)', value: '.java' },
        { label: 'C (.c)', value: '.c' },
        { label: 'C++ (.cpp)', value: '.cpp' },
        { label: 'C++ (.cc)', value: '.cc' },
        { label: 'C Header (.h)', value: '.h' },
        { label: 'Go (.go)', value: '.go' },
        { label: 'Rust (.rs)', value: '.rs' },
        { label: 'Ruby (.rb)', value: '.rb' },
        { label: 'PHP (.php)', value: '.php' }
      ]
    },
    {
      label: '脚本语言',
      options: [
        { label: 'Bash (.sh)', value: '.sh' },
        { label: 'Bash (.bash)', value: '.bash' },
        { label: 'Zsh (.zsh)', value: '.zsh' },
        { label: 'Fish (.fish)', value: '.fish' }
      ]
    },
    {
      label: '数据格式',
      options: [
        { label: 'JSON (.json)', value: '.json' },
        { label: 'YAML (.yaml)', value: '.yaml' },
        { label: 'YAML (.yml)', value: '.yml' },
        { label: 'SQL (.sql)', value: '.sql' }
      ]
    }
  ]
})

// 获取图标样式类
const getIconClass = (data) => {
  if (data.type === 'directory') {
    return 'icon-folder'
  }
  
  const fileName = data.name.toLowerCase()
  if (fileName.endsWith('.md')) return 'icon-markdown'
  if (fileName.endsWith('.js') || fileName.endsWith('.jsx')) return 'icon-javascript'
  if (fileName.endsWith('.ts') || fileName.endsWith('.tsx')) return 'icon-typescript'
  if (fileName.endsWith('.vue')) return 'icon-vue'
  if (fileName.endsWith('.json')) return 'icon-json'
  if (fileName.endsWith('.css') || fileName.endsWith('.scss') || fileName.endsWith('.less')) return 'icon-style'
  if (fileName.endsWith('.py')) return 'icon-python'
  if (fileName.endsWith('.java')) return 'icon-java'
  if (fileName.endsWith('.cpp') || fileName.endsWith('.cc') || fileName.endsWith('.c') || fileName.endsWith('.h')) return 'icon-cpp'
  if (fileName.endsWith('.go')) return 'icon-go'
  if (fileName.endsWith('.rs')) return 'icon-rust'
  if (fileName.endsWith('.rb')) return 'icon-ruby'
  if (fileName.endsWith('.php')) return 'icon-php'
  if (fileName.endsWith('.sh') || fileName.endsWith('.bash') || fileName.endsWith('.zsh') || fileName.endsWith('.fish')) return 'icon-shell'
  if (fileName.endsWith('.html') || fileName.endsWith('.xml')) return 'icon-html'
  if (fileName.endsWith('.yaml') || fileName.endsWith('.yml')) return 'icon-yaml'
  if (fileName.endsWith('.sql')) return 'icon-sql'
  if (fileName.endsWith('.txt')) return 'icon-text'
  
  return 'icon-file'
}

// 获取标签样式类
const getLabelClass = (data) => {
  if (data.type === 'directory') {
    return 'label-folder'
  }
  return 'label-file'
}

const handleNodeClick = (data) => {
  if (data.type === 'file') {
    emit('select', data.path)
  }
}

// 处理右键菜单
const handleContextMenu = (event, data) => {
  event.preventDefault()
  event.stopPropagation()
  contextMenuData.value = data
  contextMenuX.value = event.clientX
  contextMenuY.value = event.clientY
  contextMenuVisible.value = true
}

// 关闭菜单
const closeContextMenu = () => {
  contextMenuVisible.value = false
}

// 创建目录
const handleCreateDirectory = () => {
  selectedDirPath.value = contextMenuData.value.path
  newDirName.value = ''
  createDirDialogVisible.value = true
  contextMenuVisible.value = false
}

const confirmCreateDirectory = async () => {
  if (!newDirName.value.trim()) {
    ElMessage.warning('请输入目录名称')
    return
  }

  try {
    await createDirectory(selectedDirPath.value, newDirName.value)
    ElMessage.success('目录创建成功')
    createDirDialogVisible.value = false
    emit('refresh')
  } catch (error) {
    ElMessage.error(error.response?.data?.error || '创建目录失败')
  }
}

// 创建文件
const handleCreateFile = () => {
  selectedDirPath.value = contextMenuData.value.path
  newFileName.value = ''
  newFileExtension.value = '.md'
  createFileDialogVisible.value = true
  contextMenuVisible.value = false
}

const confirmCreateFile = async () => {
  if (!newFileName.value.trim()) {
    ElMessage.warning('请输入文件名')
    return
  }

  if (!newFileExtension.value) {
    ElMessage.warning('请选择文件类型')
    return
  }

  try {
    await createFile(selectedDirPath.value, newFileName.value, newFileExtension.value)
    ElMessage.success('文件创建成功')
    createFileDialogVisible.value = false
    emit('refresh')
  } catch (error) {
    ElMessage.error(error.response?.data?.error || '创建文件失败')
  }
}

// 重命名目录
const handleRenameDirectory = () => {
  renameDirPath.value = contextMenuData.value.path
  renameDirName.value = contextMenuData.value.name
  renameDirDialogVisible.value = true
  contextMenuVisible.value = false
}

const confirmRenameDirectory = async () => {
  if (!renameDirName.value.trim()) {
    ElMessage.warning('请输入新的目录名称')
    return
  }

  if (renameDirName.value === contextMenuData.value.name) {
    ElMessage.warning('新名称与原名称相同')
    return
  }

  try {
    await renameDirectory(renameDirPath.value, renameDirName.value)
    ElMessage.success('目录重命名成功')
    renameDirDialogVisible.value = false
    emit('refresh')
  } catch (error) {
    ElMessage.error(error.response?.data?.error || '重命名失败')
  }
}

// 删除目录
const handleDeleteDirectory = async () => {
  const dirName = contextMenuData.value.name
  const dirPath = contextMenuData.value.path
  
  try {
    await ElMessageBox.confirm(
      `确定要删除目录"${dirName}"吗？此操作将删除目录及其所有内容，且不可恢复！`,
      '删除确认',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning',
        confirmButtonClass: 'el-button--danger'
      }
    )
    
    contextMenuVisible.value = false
    
    await deleteDirectory(dirPath)
    ElMessage.success('目录删除成功')
    emit('refresh')
  } catch (error) {
    if (error === 'cancel') return
    ElMessage.error(error.response?.data?.error || '删除目录失败')
  }
}

// 重命名文件
const handleRenameFile = () => {
  renameFilePath.value = contextMenuData.value.path
  renameFileName.value = contextMenuData.value.name
  renameFileDialogVisible.value = true
  contextMenuVisible.value = false
}

const confirmRenameFile = async () => {
  if (!renameFileName.value.trim()) {
    ElMessage.warning('请输入新的文件名')
    return
  }

  if (renameFileName.value === contextMenuData.value.name) {
    ElMessage.warning('新名称与原名称相同')
    return
  }

  try {
    await renameFile(renameFilePath.value, renameFileName.value)
    ElMessage.success('文件重命名成功')
    renameFileDialogVisible.value = false
    emit('refresh')
  } catch (error) {
    ElMessage.error(error.response?.data?.error || '重命名失败')
  }
}

// 删除文件
const handleDeleteFile = async () => {
  const fileName = contextMenuData.value.name
  const filePath = contextMenuData.value.path
  
  try {
    await ElMessageBox.confirm(
      `确定要删除文件"${fileName}"吗？此操作不可恢复！`,
      '删除确认',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning',
        confirmButtonClass: 'el-button--danger'
      }
    )
    
    contextMenuVisible.value = false
    
    await deleteFile(filePath)
    ElMessage.success('文件删除成功')
    emit('refresh')
  } catch (error) {
    if (error === 'cancel') return
    ElMessage.error(error.response?.data?.error || '删除文件失败')
  }
}

// 悬浮事件处理
const handleNodeHover = (data) => {
  hoverNodePath.value = data.path
}

const handleNodeLeave = () => {
  hoverNodePath.value = ''
}

// 从悬浮按钮触发的处理函数
const handleCreateDirectoryFromHover = (data) => {
  contextMenuData.value = data
  handleCreateDirectory()
  hoverNodePath.value = ''
}

const handleCreateFileFromHover = (data) => {
  contextMenuData.value = data
  handleCreateFile()
  hoverNodePath.value = ''
}

const handleRenameDirectoryFromHover = (data) => {
  contextMenuData.value = data
  handleRenameDirectory()
  hoverNodePath.value = ''
}

const handleRenameFileFromHover = (data) => {
  contextMenuData.value = data
  handleRenameFile()
  hoverNodePath.value = ''
}

const handleDeleteDirectoryFromHover = (data) => {
  contextMenuData.value = data
  handleDeleteDirectory()
  hoverNodePath.value = ''
}

const handleDeleteFileFromHover = (data) => {
  contextMenuData.value = data
  handleDeleteFile()
  hoverNodePath.value = ''
}

// 弹框自动聚焦函数
const focusCreateDirInput = () => {
  createDirInputRef.value?.focus()
}

const focusCreateFileInput = () => {
  createFileInputRef.value?.focus()
}

const focusRenameDirInput = () => {
  renameDirInputRef.value?.focus()
}

const focusRenameFileInput = () => {
  renameFileInputRef.value?.focus()
}

onMounted(() => {
  // 可选：预加载支持的扩展名
  getSupportedExtensions().then(exts => {
    supportedExtensions.value = exts
  }).catch(err => {
    console.error('获取支持的扩展名失败:', err)
  })
  
  // 添加全局点击事件来关闭菜单
  document.addEventListener('click', closeContextMenu)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', closeContextMenu)
})
</script>

<style lang="scss" scoped>
.file-tree {
  height: 100%;
  padding: 0 12px;
  overflow-x: auto;
  overflow-y: auto;
  
  // 横向滚动条
  &::-webkit-scrollbar {
    width: 6px;
    height: 6px;
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

  :deep(.el-tree) {
    background-color: transparent;
    min-width: max-content;

    .el-tree-node__content {
      height: 38px;
      border-radius: 8px;
      margin: 2px 0;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      position: relative;

      &:hover {
        background: linear-gradient(90deg, #f5f7fa 0%, #e8ecf1 100%);
        transform: translateX(4px);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
      }
    }

    .el-tree-node.is-current > .el-tree-node__content {
      background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
      box-shadow: 0 2px 12px rgba(66, 153, 225, 0.15);
      font-weight: 500;
    }

    .el-tree-node__expand-icon {
      color: #7c3aed;
      font-size: 14px;
      transition: all 0.3s;
      
      &.is-leaf {
        color: transparent;
      }
    }
  }

  .tree-node {
    display: flex;
    align-items: center;
    gap: 10px;
    flex: 1;
    position: relative;

    &.is-directory {
      font-weight: 500;
    }

    .node-label {
      font-size: 14px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      transition: all 0.2s;
      flex: 1;
      
      &.label-folder {
        color: #3b82f6;
        font-weight: 600;
      }
      
      &.label-file {
        color: #4b5563;
      }
    }

    // 悬浮操作按钮
    .node-actions {
      display: flex;
      align-items: center;
      gap: 1px;
      height: 20px;
      padding: 0 4px;
      margin-left: auto;
      background: linear-gradient(135deg, #f8fafc 0%, #e0e7ff 100%);
      border: 1px solid #c7d2fe;
      border-radius: 4px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

      :deep(.el-button) {
        padding: 2px;
        min-height: 16px;
        width: 16px;
        
        .el-icon {
          font-size: 12px;
        }
        
        &.is-text:not(.is-disabled):hover {
          background-color: rgba(64, 158, 255, 0.15);
        }

        &[type="danger"]:hover {
          background-color: rgba(245, 108, 108, 0.15);
          color: #f56c6c;
        }
      }
    }
  }

  // 文件夹图标样式
  .icon-folder {
    color: #f59e0b;
    filter: drop-shadow(0 2px 4px rgba(245, 158, 11, 0.2));
    transition: all 0.3s;

    &:hover {
      transform: scale(1.1);
    }
  }

  // Markdown 文件图标
  .icon-markdown {
    color: #06b6d4;
    filter: drop-shadow(0 2px 4px rgba(6, 182, 212, 0.2));
  }

  // JavaScript 文件图标
  .icon-javascript {
    color: #eab308;
    filter: drop-shadow(0 2px 4px rgba(234, 179, 8, 0.2));
  }

  // Vue 文件图标
  .icon-vue {
    color: #10b981;
    filter: drop-shadow(0 2px 4px rgba(16, 185, 129, 0.2));
  }

  // JSON 文件图标
  .icon-json {
    color: #8b5cf6;
    filter: drop-shadow(0 2px 4px rgba(139, 92, 246, 0.2));
  }

  // 样式文件图标
  .icon-style {
    color: #ec4899;
    filter: drop-shadow(0 2px 4px rgba(236, 72, 153, 0.2));
  }

  // Python 文件图标
  .icon-python {
    color: #3776ab;
    filter: drop-shadow(0 2px 4px rgba(55, 118, 171, 0.2));
  }

  // TypeScript 文件图标
  .icon-typescript {
    color: #3178c6;
    filter: drop-shadow(0 2px 4px rgba(49, 120, 198, 0.2));
  }

  // Java 文件图标
  .icon-java {
    color: #f89820;
    filter: drop-shadow(0 2px 4px rgba(248, 152, 32, 0.2));
  }

  // C++ 文件图标
  .icon-cpp {
    color: #00599c;
    filter: drop-shadow(0 2px 4px rgba(0, 89, 156, 0.2));
  }

  // Go 文件图标
  .icon-go {
    color: #00add8;
    filter: drop-shadow(0 2px 4px rgba(0, 173, 216, 0.2));
  }

  // Rust 文件图标
  .icon-rust {
    color: #ce422b;
    filter: drop-shadow(0 2px 4px rgba(206, 66, 43, 0.2));
  }

  // Ruby 文件图标
  .icon-ruby {
    color: #cc342d;
    filter: drop-shadow(0 2px 4px rgba(204, 52, 45, 0.2));
  }

  // PHP 文件图标
  .icon-php {
    color: #777bb4;
    filter: drop-shadow(0 2px 4px rgba(119, 123, 180, 0.2));
  }

  // Shell 文件图标
  .icon-shell {
    color: #4ee34e;
    filter: drop-shadow(0 2px 4px rgba(78, 227, 78, 0.2));
  }

  // HTML 文件图标
  .icon-html {
    color: #e34c26;
    filter: drop-shadow(0 2px 4px rgba(227, 76, 38, 0.2));
  }

  // YAML 文件图标
  .icon-yaml {
    color: #cb171e;
    filter: drop-shadow(0 2px 4px rgba(203, 23, 30, 0.2));
  }

  // SQL 文件图标
  .icon-sql {
    color: #336791;
    filter: drop-shadow(0 2px 4px rgba(51, 103, 145, 0.2));
  }

  // 文本文件图标
  .icon-text {
    color: #9ca3af;
    filter: drop-shadow(0 2px 4px rgba(156, 163, 175, 0.2));
  }

  // 默认文件图标
  .icon-file {
    color: #6b7280;
    filter: drop-shadow(0 2px 4px rgba(107, 114, 128, 0.2));
  }

  .loading-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 200px;
    color: #909399;

    p {
      margin-top: 12px;
      font-size: 14px;
    }
  }
}

// 对话框样式
.create-file-form {
  display: flex;
  flex-direction: column;
  gap: 16px;

  .form-group {
    display: flex;
    flex-direction: column;
    gap: 8px;

    label {
      font-weight: 500;
      color: #303133;
      font-size: 14px;
    }
  }
}

// 右键菜单样式
.context-menu {
  position: fixed;
  background: white;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  z-index: 2000;
  min-width: 150px;
  padding: 4px 0;

  .context-menu-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    cursor: pointer;
    font-size: 14px;
    color: #303133;
    transition: all 0.2s;

    &:hover {
      background-color: #f5f7fa;
      color: #409eff;
    }

    &.delete-item {
      color: #f56c6c;

      &:hover {
        background-color: #fef0f0;
        color: #f56c6c;
      }
    }

    span {
      flex: 1;
    }
  }

  .context-menu-divider {
    height: 1px;
    background-color: #ebeef5;
    margin: 4px 0;
  }
}
</style>
