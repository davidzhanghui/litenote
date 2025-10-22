import express from 'express'
import cors from 'cors'
import fs from 'fs/promises'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT = 30001

// Markdown 文件目录
const MARKDOWNS_DIR = path.join(__dirname, '../markdowns')

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
      } else if (entry.isFile() && entry.name.endsWith('.md')) {
        items.push({
          name: entry.name,
          path: relPath,
          type: 'file'
        })
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
    // 确保 markdowns 目录存在
    try {
      await fs.access(MARKDOWNS_DIR)
    } catch {
      await fs.mkdir(MARKDOWNS_DIR, { recursive: true })
    }
    
    const tree = await readDirectoryTree(MARKDOWNS_DIR)
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
    const fullPath = path.join(MARKDOWNS_DIR, filePath)
    if (!fullPath.startsWith(MARKDOWNS_DIR)) {
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
    const fullPath = path.join(MARKDOWNS_DIR, filePath)
    if (!fullPath.startsWith(MARKDOWNS_DIR)) {
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

app.listen(PORT, () => {
  console.log(`服务器运行在 http://localhost:${PORT}`)
  console.log(`Markdown 文件目录: ${MARKDOWNS_DIR}`)
})
