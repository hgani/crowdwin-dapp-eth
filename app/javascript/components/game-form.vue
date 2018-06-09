<template lang="pug">
  div
    .form-group
      label Closing Time
      input.form-control(type="datetime-local" v-model="game.closingTime" :min="game.minimumTime" style="width: 300px" required)
    .form-group
      label Title
      input.form-control(type="text" v-model="game.label")
    .form-group(v-for="(item, index) in game.options")
      label Option {{index + 1}}
      input.form-control(v-model="game.options[index]")
    .form-group
      button.btn.btn-primary(@click="submit" :disabled="submitting") 
        | {{ editMode ? 'Submit' : 'Create New Game' }}
</template>

<script>
export default {
  props: ["csrfToken", "readOnlyGame", "submitting", "editMode"],
  data() {
    return {
      game: {}
    };
  },
  watch: {
    readOnlyGame(value) {
      const self = this;

      self.game = _.cloneDeep(self.readOnlyGame);
    }
  },
  created() {
    const self = this;

    self.game = _.cloneDeep(self.readOnlyGame);
  },
  methods: {
    submit() {
      const self = this;

      self.$emit("submit", _.cloneDeep(self.game));
    }
  }
};
</script>
