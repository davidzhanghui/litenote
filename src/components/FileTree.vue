<template>
  <div class="file-tree">
    <el-tree
      v-if="!loading && treeData.length > 0"
      :data="treeData"
      :props="treeProps"
      node-key="path"
      highlight-current
      :expand-on-click-node="false"
      @node-click="handleNodeClick"
    >
      <template #default="{ node, data }">
        <span class="tree-node">
          <el-icon :size="16">
            <Folder v-if="data.type === 'directory'" />
            <Document v-else />
          </el-icon>
          <span class="node-label">{{ node.label }}</span>
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
import { Folder, Document, Loading } from '@element-plus/icons-vue'

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
      height: 36px;
      border-radius: 6px;
      transition: all 0.2s;

      &:hover {
        background-color: #f5f7fa;
      }
    }

    .el-tree-node.is-current > .el-tree-node__content {
      background-color: #ecf5ff;
      color: #409eff;
    }
  }

  .tree-node {
    display: flex;
    align-items: center;
    gap: 8px;
    flex: 1;

    .node-label {
      font-size: 14px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
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
