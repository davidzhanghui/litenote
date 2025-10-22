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
