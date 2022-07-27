# YUYUKO-BOOK

```shell
# build
hugo -D
# run server
hugo server -D
```

## develop

themes文档： `https://mcshelby.github.io/hugo-theme-relearn/`

markdown文档： `https://learn.netlify.app/en/cont/markdown/`

流程图： `https://mermaid-js.github.io/mermaid/#/`

图标： `https://fontawesome.com/icons?d=gallery&m=free`
`https://www.fontawesomecheatsheet.com/font-awesome-cheatsheet-5x/`

ppt: `https://github.com/marp-team/marp`

新建：
```shell
# 新增普通页
hugo new ops/first.md
# 新增章节主页
hugo new --kind chapter ops/tools/_index.md
```

## ppt生成

vscode 插件： https://github.com/marp-team/marp-vscode

markdown 扩展项目： https://marp.app/#get-started


marp工具扩展markdown，用markdown编辑ppt

## deploy

更改config中的`baseURL`变量

- static/css变更覆盖themes中的css
- layouts变更页面元素
