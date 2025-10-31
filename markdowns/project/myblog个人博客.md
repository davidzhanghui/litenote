1. 先和llm聊需求，输出需求文档和技术文档
2. 再让llm根据需求文档和技术文档列出开发计划
3. 让llm一个个的去完成开发计划。每完成一个开发计划，让llm写脚本测试后端接口（需要登录的接口告诉llm用什么用户去登录），前端接口让llm使用chrome devtool的mcp去自己测试。测试通过后，记得提交一下代码。
   1. 后端测试： 测试TagController的所有接口。注意：1.contextPath是/api，所以所有接口都是以/api开头。2.如果接口需要登录，使用用户（testuser 123456）登录，如果接口需要ADMIN角色登录，这使用用户（admin admin123）登录
   2. 前端测试： @development-plan.md 1. 对照代码检查week2中的所有前端开发任务，看看是否都已经确定完成了，没有完成的要全部做完。2.步骤1完成后，使用【chrome-devtools】这个mcp工具，检查week2中的所有前端开发任务是否能正常运行
   3. 前端测试2: 请使用 chrome-devtools MCP 工具访问 http://localhost:5173 并测试以下功能： 1. 评论功能 2. 点赞功能 3.搜索功能。 测试过程中使用用户（testuser 123456）登录。

