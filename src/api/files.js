import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// 获取文件树
export const getFileTree = async () => {
  try {
    const response = await api.get('/files')
    return response.data
  } catch (error) {
    console.error('获取文件树失败:', error)
    throw error
  }
}

// 获取文件内容
export const getFileContent = async (filePath) => {
  try {
    const response = await api.get('/file', {
      params: { path: filePath }
    })
    return response.data.content
  } catch (error) {
    console.error('获取文件内容失败:', error)
    throw error
  }
}

// 保存文件内容
export const saveFileContent = async (filePath, content) => {
  try {
    const response = await api.post('/file', {
      path: filePath,
      content
    })
    return response.data
  } catch (error) {
    console.error('保存文件失败:', error)
    throw error
  }
}

// 创建目录
export const createDirectory = async (parentPath, name) => {
  try {
    const response = await api.post('/directory', {
      path: parentPath,
      name
    })
    return response.data
  } catch (error) {
    console.error('创建目录失败:', error)
    throw error
  }
}

// 重命名目录
export const renameDirectory = async (dirPath, newName) => {
  try {
    const response = await api.put('/directory', {
      path: dirPath,
      newName
    })
    return response.data
  } catch (error) {
    console.error('重命名目录失败:', error)
    throw error
  }
}

// 创建文件
export const createFile = async (parentPath, name, extension) => {
  try {
    const response = await api.post('/create-file', {
      path: parentPath,
      name,
      extension
    })
    return response.data
  } catch (error) {
    console.error('创建文件失败:', error)
    throw error
  }
}

// 删除目录
export const deleteDirectory = async (dirPath) => {
  try {
    const response = await api.delete('/directory', {
      data: { path: dirPath }
    })
    return response.data
  } catch (error) {
    console.error('删除目录失败:', error)
    throw error
  }
}

// 删除文件
export const deleteFile = async (filePath) => {
  try {
    const response = await api.delete('/file', {
      data: { path: filePath }
    })
    return response.data
  } catch (error) {
    console.error('删除文件失败:', error)
    throw error
  }
}

// 重命名文件
export const renameFile = async (filePath, newName) => {
  try {
    const response = await api.put('/file-rename', {
      path: filePath,
      newName
    })
    return response.data
  } catch (error) {
    console.error('重命名文件失败:', error)
    throw error
  }
}

// 获取支持的文件扩展名
export const getSupportedExtensions = async () => {
  try {
    const response = await api.get('/supported-extensions')
    return response.data.extensions
  } catch (error) {
    console.error('获取支持的文件扩展名失败:', error)
    throw error
  }
}
