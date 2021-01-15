<template>
  <div v-if="modelValue.loading">Loading...</div>
  <pre v-else-if="modelValue.error">{{ modelValue.error }}</pre>
  <div v-else>
    <div
      class="message"
      v-for="message in modelValue.data.messages"
      :key="message.id"
    >
      <p>{{ message.text }}</p>
      <pre v-if="Object.keys(message.context).length > 0">
            {{ message.context }}
        </pre
      >
    </div>
    <div
      v-for="{ method, config: form } in modelValue.data.methods"
      :key="method"
    >
      <form :action="form.action" :method="form.method">
        <div class="error" v-for="message in form.messages" :key="message.id">
          <p>{{ message.text }}</p>
          <pre v-if="Object.keys(message.context).length > 0">
            {{ message.context }}
          </pre>
        </div>
        <template v-for="field in form.fields" :key="field.name">
          <label v-if="field.type !== 'hidden'" :for="field.name">
            {{ field.name }}
          </label>
          <input
            :name="field.name"
            :type="field.type"
            :value="field.value"
            :required="field.required"
          />
          <div
            class="error"
            v-for="message in field.messages"
            :key="message.id"
          >
            <p>{{ message.text }}</p>
            <pre>{{ message.context }}</pre>
          </div>
        </template>
        <input type="submit" value="Submit" />
      </form>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    modelValue: Object
  },
  setup(props) {
    return props;
  }
};
</script>

<style scoped lang="scss">
form {
  margin: 15px;
  width: 500px;
  display: grid;
  grid-template-columns: 100px 1fr;
  grid-gap: 5px;
  label {
    grid-column: 1 / 2;
  }
  p {
    padding: 0;
    margin: 0;
  }
  input,
  .error {
    grid-column: 2 / 3;
  }
  input[type="submit"] {
    grid-column-start: 1;
    grid-column-end: 3;
  }
}
</style>
