<template>
  <div class="file-tree">
    <el-tree
      v-if="!loading && treeData.length > 0"
      :data="treeData"
      :props="treeProps"
      node-key="path"
      highlight-current
      :expand-on-click-node="false"
      default-expand-all
      @node-click="handleNodeClick"
    >
      <template #default="{ node, data }">
        <span class="tree-node" :class="{ 'is-directory': data.type === 'directory', 'is-file': data.type === 'file' }">
          <el-icon :size="18" :class="getIconClass(data)">
            <FolderOpened v-if="data.type === 'directory' && node.expanded" />
            <Folder v-else-if="data.type === 'directory'" />
            <Document v-else />
          </el-icon>
          <span class="node-label" :class="getLabelClass(data)">{{ node.label }}</span>
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
  </div>
</template>

<script setup>
import { Folder, FolderOpened, Document, Loading } from '@element-plus/icons-vue'

defineProps({
  treeData: {
    type: Array,
    default: () => []
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['select'])

const treeProps = {
  children: 'children',
  label: 'name'
}

// 获取图标样式类
const getIconClass = (data) => {
  if (data.type === 'directory') {
    return 'icon-folder'
  }
  
  // 根据文件扩展名返回不同的类
  const fileName = data.name.toLowerCase()
  if (fileName.endsWith('.md')) return 'icon-markdown'
  if (fileName.endsWith('.js')) return 'icon-javascript'
  if (fileName.endsWith('.vue')) return 'icon-vue'
  if (fileName.endsWith('.json')) return 'icon-json'
  if (fileName.endsWith('.css') || fileName.endsWith('.scss')) return 'icon-style'
  
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
</script>

<style lang="scss" scoped>
.file-tree {
  height: 100%;
  padding: 0 12px;

  :deep(.el-tree) {
    background-color: transparent;

    .el-tree-node__content {
      height: 38px;
      border-radius: 8px;
      margin: 2px 0;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);

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

    &.is-directory {
      font-weight: 500;
    }

    .node-label {
      font-size: 14px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      transition: all 0.2s;
      
      &.label-folder {
        color: #3b82f6;
        font-weight: 600;
      }
      
      &.label-file {
        color: #4b5563;
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
</style>
