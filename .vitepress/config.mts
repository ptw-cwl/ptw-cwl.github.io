import { defineConfig } from 'vitepress'
export default defineConfig({
  title: "ptw-cwl",
  titleTemplate: ':title',
  description: "个人博客",
  head: [['link', { rel: 'icon', href: '/assets/img/logo.png' }]],
  lang: 'zh-CN',
  cleanUrls: true,
  srcExclude: ['**/README.md', '**/TODO.md'],
  ignoreDeadLinks: true,
  metaChunk: true,
  lastUpdated: true,
  sitemap: {
    hostname: 'https://ptw-cwl.com',
    lastmodDateOnly: false
  },
  themeConfig: {
    logo: '/assets/img/logo.png',
    siteTitle: 'ptw-cwl',
    nav: [
      {
        text: '主页',
        link: '/',
        target: '_self',
        rel: 'ptw-cwl的个人博客'
      },
      {
        text: '关于',
        link: '/about.html',
        target: '_self',
        rel: 'ptw-cwl的介绍'
      },
      {
        text: '专栏',
        link: '/docs/',
        target: '_self',
        rel: 'ptw-cwl的专栏'
      }
    ],
    sidebar: {
      '/docs/java/': [
        {
          text: 'JAVA专栏',
          link: '/docs/java/'
        },
        {
          text: '精选文章',
          collapsed: true,
          items: [
            {
              text: 'test',
              link: '/docs/java/test'
            }
          ]
        }
      ],
      '/docs/mysql/': [
        {
          text: 'MySQL专栏',
          link: '/docs/'
        },
        {
          text: '精选文章',
          collapsed: true,
          items: [
            {
              text: 'test',
              link: '/docs/mysql/test'
            }
          ]
        }
      ],
      '/docs/problem/': [
        {
          text: '问题专栏',
          link: '/docs/problem/'
        },
        {
          text: '精选文章',
          collapsed: true,
          items: [
            {
              text: 'test',
              link: '/docs/problem/test'
            }
          ]
        }
      ]
    },
    footer: {
      message: '转载请注明出处',
      copyright: '版权 © 2024 Ptw-Cwl'
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/ptw-cwl' }
    ],
    editLink: {
      pattern: 'https://github.com/ptw-cwl/ptw-cwl.github.io/edit/main/:path',
      text: '在 GitHub 上编辑此页面'
    },
    lastUpdated: {
      text: '更新于',
      formatOptions: {
        dateStyle: 'full',
        timeStyle: 'medium'
      }
    },
    search: {
      provider: 'local',
      options: {
        translations: {
          button: {
            buttonText: '搜索文档',
            buttonAriaLabel: '搜索文档'
          },
          modal: {
            noResultsText: '无法找到相关结果',
            resetButtonTitle: '清除查询条件',
            footer: {
              selectText: '选择',
              navigateText: '切换'
            }
          }
        }
      }
    },
    docFooter: {
      prev: '上一页',
      next: '下一页'
    }
  }
})
