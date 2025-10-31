import express from 'express'
import cors from 'cors'
import fs from 'fs/promises'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT = 30001

// 文件目录
const NOTES_DIR = path.join(__dirname, '../notes')

app.use(cors())
app.use(express.json())

// 递归读取目录结构
async function readDirectoryTree(dirPath, relativePath = '') {
  const items = []
  
  try {
    const entries = await fs.readdir(dirPath, { withFileTypes: true })
    
    for (const entry of entries) {
      const fullPath = path.join(dirPath, entry.name)
      const relPath = relativePath ? `${relativePath}/${entry.name}` : entry.name
      
      if (entry.isDirectory()) {
        const children = await readDirectoryTree(fullPath, relPath)
        items.push({
          name: entry.name,
          path: relPath,
          type: 'directory',
          children
        })
      } else if (entry.isFile()) {
        // 支持多种文件类型
        const supportedExtensions = [
          '.md', '.txt',
          '.js', '.jsx', '.ts', '.tsx', '.vue',
          '.py', '.java', '.cpp', '.c', '.h', '.go', '.rs', '.rb', '.php',
          '.sh', '.bash', '.zsh', '.fish',
          '.json', '.yaml', '.yml', '.xml', '.html', '.css', '.scss', '.less',
          '.sql', '.sql'
        ]
        
        const isSupportedFile = supportedExtensions.some(ext => 
          entry.name.toLowerCase().endsWith(ext)
        )
        
        if (isSupportedFile) {
          items.push({
            name: entry.name,
            path: relPath,
            type: 'file'
          })
        }
      }
    }
  } catch (error) {
    console.error(`读取目录失败 ${dirPath}:`, error)
  }
  
  return items
}

// API: 获取文件树
app.get('/api/files', async (req, res) => {
  try {
    // 确保 notes 目录存在
    try {
      await fs.access(NOTES_DIR)
    } catch {
      await fs.mkdir(NOTES_DIR, { recursive: true })
    }
    
    const tree = await readDirectoryTree(NOTES_DIR)
    res.json(tree)
  } catch (error) {
    console.error('获取文件树失败:', error)
    res.status(500).json({ error: '获取文件树失败' })
  }
})

// API: 读取文件内容
app.get('/api/file', async (req, res) => {
  try {
    const { path: filePath } = req.query
    
    if (!filePath) {
      return res.status(400).json({ error: '文件路径不能为空' })
    }
    
    // 防止路径遍历攻击
    const fullPath = path.join(NOTES_DIR, filePath)
    if (!fullPath.startsWith(NOTES_DIR)) {
      return res.status(403).json({ error: '非法的文件路径' })
    }
    
    const content = await fs.readFile(fullPath, 'utf-8')
    res.json({ content })
  } catch (error) {
    console.error('读取文件失败:', error)
    res.status(500).json({ error: '读取文件失败' })
  }
})

// API: 保存文件内容
app.post('/api/file', async (req, res) => {
  try {
    const { path: filePath, content } = req.body
    
    if (!filePath) {
      return res.status(400).json({ error: '文件路径不能为空' })
    }
    
    // 防止路径遍历攻击
    const fullPath = path.join(NOTES_DIR, filePath)
    if (!fullPath.startsWith(NOTES_DIR)) {
      return res.status(403).json({ error: '非法的文件路径' })
    }
    
    // 确保目录存在
    const dirPath = path.dirname(fullPath)
    await fs.mkdir(dirPath, { recursive: true })
    
    // 写入文件
    await fs.writeFile(fullPath, content, 'utf-8')
    
    res.json({ success: true })
  } catch (error) {
    console.error('保存文件失败:', error)
    res.status(500).json({ error: '保存文件失败' })
  }
})

// 支持的文件扩展名
const SUPPORTED_EXTENSIONS = [
  '.md', '.txt',
  '.js', '.jsx', '.ts', '.tsx', '.vue',
  '.py', '.java', '.cpp', '.c', '.h', '.cc', '.go', '.rs', '.rb', '.php',
  '.sh', '.bash', '.zsh', '.fish',
  '.json', '.yaml', '.yml', '.xml', '.html', '.css', '.scss', '.less',
  '.sql'
]

// API: 创建目录
app.post('/api/directory', async (req, res) => {
  try {
    const { path: dirPath, name } = req.body
    
    if (!name) {
      return res.status(400).json({ error: '目录名不能为空' })
    }
    
    // 验证目录名（不允许特殊字符）
    if (!/^[a-zA-Z0-9_\-\u4e00-\u9fff]+$/.test(name)) {
      return res.status(400).json({ error: '目录名只能包含字母、数字、下划线、中划线和中文' })
    }
    
    const newDirPath = dirPath ? `${dirPath}/${name}` : name
    const fullPath = path.join(NOTES_DIR, newDirPath)
    
    // 防止路径遍历攻击
    if (!fullPath.startsWith(NOTES_DIR)) {
      return res.status(403).json({ error: '非法的目录路径' })
    }
    
    // 检查是否已存在
    try {
      await fs.access(fullPath)
      return res.status(409).json({ error: '目录已存在' })
    } catch {
      // 目录不存在，继续创建
    }
    
    await fs.mkdir(fullPath, { recursive: true })
    res.json({ success: true, path: newDirPath })
  } catch (error) {
    console.error('创建目录失败:', error)
    res.status(500).json({ error: '创建目录失败' })
  }
})

// API: 重命名目录
app.put('/api/directory', async (req, res) => {
  try {
    const { path: oldPath, newName } = req.body
    
    if (!oldPath || !newName) {
      return res.status(400).json({ error: '路径和新名称不能为空' })
    }
    
    // 验证新名称
    if (!/^[a-zA-Z0-9_\-\u4e00-\u9fff]+$/.test(newName)) {
      return res.status(400).json({ error: '目录名只能包含字母、数字、下划线、中划线和中文' })
    }
    
    const oldFullPath = path.join(NOTES_DIR, oldPath)
    const parentDir = path.dirname(oldFullPath)
    const newFullPath = path.join(parentDir, newName)
    
    // 防止路径遍历攻击
    if (!oldFullPath.startsWith(NOTES_DIR) || !newFullPath.startsWith(NOTES_DIR)) {
      return res.status(403).json({ error: '非法的目录路径' })
    }
    
    // 检查新名称是否已存在
    try {
      await fs.access(newFullPath)
      return res.status(409).json({ error: '目录已存在' })
    } catch {
      // 新目录不存在，继续重命名
    }
    
    await fs.rename(oldFullPath, newFullPath)
    const newPath = oldPath.substring(0, oldPath.lastIndexOf('/')) + '/' + newName
    res.json({ success: true, newPath: newPath.startsWith('/') ? newPath.substring(1) : newPath })
  } catch (error) {
    console.error('重命名目录失败:', error)
    res.status(500).json({ error: '重命名目录失败' })
  }
})

// API: 创建文件
app.post('/api/create-file', async (req, res) => {
  try {
    const { path: filePath, name, extension } = req.body
    
    if (!name || !extension) {
      return res.status(400).json({ error: '文件名和扩展名不能为空' })
    }
    
    // 验证文件名
    if (!/^[a-zA-Z0-9_\-\u4e00-\u9fff]+$/.test(name)) {
      return res.status(400).json({ error: '文件名只能包含字母、数字、下划线、中划线和中文' })
    }
    
    // 验证扩展名
    if (!SUPPORTED_EXTENSIONS.includes(extension)) {
      return res.status(400).json({ error: '不支持的文件类型' })
    }
    
    const fileName = `${name}${extension}`
    const newFilePath = filePath ? `${filePath}/${fileName}` : fileName
    const fullPath = path.join(NOTES_DIR, newFilePath)
    
    // 防止路径遍历攻击
    if (!fullPath.startsWith(NOTES_DIR)) {
      return res.status(403).json({ error: '非法的文件路径' })
    }
    
    // 检查是否已存在
    try {
      await fs.access(fullPath)
      return res.status(409).json({ error: '文件已存在' })
    } catch {
      // 文件不存在，继续创建
    }
    
    // 确保目录存在
    const dirPath = path.dirname(fullPath)
    await fs.mkdir(dirPath, { recursive: true })
    
    // 创建空文件
    await fs.writeFile(fullPath, '', 'utf-8')
    
    res.json({ success: true, path: newFilePath })
  } catch (error) {
    console.error('创建文件失败:', error)
    res.status(500).json({ error: '创建文件失败' })
  }
})

// API: 删除目录
app.delete('/api/directory', async (req, res) => {
  try {
    const { path: dirPath } = req.body
    
    if (!dirPath) {
      return res.status(400).json({ error: '目录路径不能为空' })
    }
    
    const fullPath = path.join(NOTES_DIR, dirPath)
    
    // 防止路径遍历攻击
    if (!fullPath.startsWith(NOTES_DIR)) {
      return res.status(403).json({ error: '非法的目录路径' })
    }
    
    // 防止删除根目录
    if (fullPath === NOTES_DIR) {
      return res.status(403).json({ error: '不能删除根目录' })
    }
    
    // 检查目录是否存在
    try {
      const stats = await fs.stat(fullPath)
      if (!stats.isDirectory()) {
        return res.status(400).json({ error: '路径不是目录' })
      }
    } catch {
      return res.status(404).json({ error: '目录不存在' })
    }
    
    // 递归删除目录
    await fs.rm(fullPath, { recursive: true, force: true })
    
    res.json({ success: true })
  } catch (error) {
    console.error('删除目录失败:', error)
    res.status(500).json({ error: '删除目录失败' })
  }
})

// API: 删除文件
app.delete('/api/file', async (req, res) => {
  try {
    const { path: filePath } = req.body
    
    if (!filePath) {
      return res.status(400).json({ error: '文件路径不能为空' })
    }
    
    const fullPath = path.join(NOTES_DIR, filePath)
    
    // 防止路径遍历攻击
    if (!fullPath.startsWith(NOTES_DIR)) {
      return res.status(403).json({ error: '非法的文件路径' })
    }
    
    // 检查文件是否存在
    try {
      const stats = await fs.stat(fullPath)
      if (!stats.isFile()) {
        return res.status(400).json({ error: '路径不是文件' })
      }
    } catch {
      return res.status(404).json({ error: '文件不存在' })
    }
    
    // 删除文件
    await fs.unlink(fullPath)
    
    res.json({ success: true })
  } catch (error) {
    console.error('删除文件失败:', error)
    res.status(500).json({ error: '删除文件失败' })
  }
})

// API: 重命名文件
app.put('/api/file-rename', async (req, res) => {
  try {
    const { path: oldPath, newName } = req.body
    
    if (!oldPath || !newName) {
      return res.status(400).json({ error: '路径和新名称不能为空' })
    }
    
    const oldFullPath = path.join(NOTES_DIR, oldPath)
    const parentDir = path.dirname(oldFullPath)
    const newFullPath = path.join(parentDir, newName)
    
    // 防止路径遍历攻击
    if (!oldFullPath.startsWith(NOTES_DIR) || !newFullPath.startsWith(NOTES_DIR)) {
      return res.status(403).json({ error: '非法的文件路径' })
    }
    
    // 检查新名称是否已存在
    try {
      await fs.access(newFullPath)
      return res.status(409).json({ error: '文件已存在' })
    } catch {
      // 新文件不存在，继续重命名
    }
    
    await fs.rename(oldFullPath, newFullPath)
    const newPath = oldPath.substring(0, oldPath.lastIndexOf('/')) + '/' + newName
    res.json({ success: true, newPath: newPath.startsWith('/') ? newPath.substring(1) : newPath })
  } catch (error) {
    console.error('重命名文件失败:', error)
    res.status(500).json({ error: '重命名文件失败' })
  }
})

// API: 获取支持的文件扩展名
app.get('/api/supported-extensions', (req, res) => {
  res.json({ extensions: SUPPORTED_EXTENSIONS })
})

app.listen(PORT, () => {
  console.log(`服务器运行在 http://localhost:${PORT}`)
  console.log(`文件目录: ${NOTES_DIR}`)
})
