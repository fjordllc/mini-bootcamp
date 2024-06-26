<template lang="pug">
p.is-size-6
  span.has-text-success.has-text-weight-bold(v-if="challenge.archivement")
    i.fas.fa-check.mr-1
    | 達成済
  span.has-text-grey-light.has-text-weight-bold(v-else)
    | 未クリア
h1.title.is-3
  span.tag.is-black.mr-2
    | {{ challenge.category }}
  | {{ challenge.title }}
.workspace
  .columns
    .column(style="white-space: pre-wrap")
      h5.title.is-5.mb-2 問題
      #content.markdown-body
    .column
      Editor(
        ref="editor"
        v-model="codeInput"
      )
      Runner(
        :id="challenge.id"
        :checks="challenge.checks"
        :code="codeInput"
      )
Checker(
  :id="challenge.id"
  :checks="challenge.checks"
  :code="codeInput"
  :nextChallenge="next"
  @set-answer="modelAnswer.set($event)"
  @open-modal="modelAnswer.openModal()"
)
ModelAnswer(
  ref="modelAnswer"
)
hr(v-if="previous.url || next.url")
nav.level
  .level-left
    .level-item(v-if="previous.url")
      a.button.is-small(:href="previous.url")
        span.icon.is-small
          i.fas.fa-caret-left
        span {{ previous.title }}
  .level-right
    .level-item(v-if="next.url")
      a.button.is-small(:href="next.url")
        span {{ next.title }}
        span.icon.is-small
          i.fas.fa-caret-right
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'
import axios from 'axios'
import { setHeaders } from './modules/set_headers'
import MarkdownIt from 'markdown-it'

import Editor from './components/Editor.vue'
import Runner from './components/Runner.vue'
import Checker from './components/Checker.vue'
import ModelAnswer from './components/ModelAnswer.vue'

export default {
  name: 'Challenge',
  props: {
    id: {
      type: Number,
      required: true
    }
  },
  components: {
    Editor,
    Runner,
    Checker,
    ModelAnswer
  },
  setup (props) {
    onMounted(() => {
      getChallengeContent()
        .then(mode => {
          editor.value.setupEditor(mode)
          modelAnswer.value.setupEditor(mode)
        })
    })

    // Challenge
    const challenge = reactive({
      id: props.id,
      title: '',
      content: '',
      checks: [],
      archivement: null,
      category: ''
    })
    const previous = reactive({
      title: null,
      url: null
    })
    const next = reactive({
      title: null,
      url: null
    })

    const getChallengeContent = async () => {
      setHeaders(axios)
      const response = await axios.get(`/api/challenges/${props.id}`).catch(error => console.log(error.response))
      const data = response.data

      challenge.title = data.title
      challenge.content = data.content
      challenge.archivement = data.archivement
      challenge.category = data.category
      previous.title = data.previous ? data.previous.title : null
      previous.url = data.previous ? data.previous.url : null
      next.title = data.next ? data.next.title : null
      next.url = data.next ? data.next.url : null

      const content = document.getElementById('content')
      content.innerHTML = new MarkdownIt().render(challenge.content)

      data.checks.forEach((check, i) => {
        const checkWithIndex = { ...check, ...{ index: i } }
        challenge.checks.push(checkWithIndex)
      })

      return data.mode
    }

    // Editor
    const editor = ref()
    const codeInput = ref('')
    const modelAnswer = ref()

    return {
      challenge,
      previous,
      next,
      editor,
      codeInput,
      modelAnswer
    }
  }
}
</script>

<style scoped>
  table {
    white-space: pre;
  }

  table th {
    font-weight: normal;
    font-size: 0.75rem;
    vertical-align: middle;
  }
  .loading-cover {
    display: flex;
    position: absolute;
    width: calc(100% + 2px);
    height: calc(100% + 2px);
    z-index: 10;
    top: -1px;
    left: -1px;
    background: #ffffffcc;
  }
</style>
