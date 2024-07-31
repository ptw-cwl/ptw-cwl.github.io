---
layout: page
sidebar: false
---
<script setup>
import {
  VPTeamPage,
  VPTeamPageTitle,
  VPTeamMembers,
  VPTeamPageSection
} from 'vitepress/theme'

const coreMembers = [{
    avatar: '/assets/img/logo.png',
    name: 'ptw-cwl',
    title: '记录个人成长',
    links: [
      {icon: 'github', link: 'https://github.com/ptw-cwl' }
    ]
}]
const partners = []
</script>

<VPTeamPage>
  <VPTeamPageTitle>
    <template #title>团队</template>
    <template #lead>记录个人成长</template>
  </VPTeamPageTitle>
  <VPTeamMembers size="medium" :members="coreMembers" />
  <VPTeamPageSection>
    <template #title>伙伴</template>
    <template #lead>暂无</template>
    <template #members>
      <VPTeamMembers size="small" :members="partners" />
    </template>
  </VPTeamPageSection>
</VPTeamPage>