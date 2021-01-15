<template>
  <div v-if="data.error">
    <h1>{{ data.error.status }} ({{ data.error.code }})</h1>
    <p>{{ data.error.reason }}</p>
    <p>{{ data.error.message }}</p>

    <pre>{{ data.error.details }}</pre>
  </div>
  <div v-else-if="data">
    <div v-for="(method, name) in data.methods" :key="name">
      <form :action="method.config.action" :method="method.config.method">
        <div
          class="error"
          v-for="message in method.config.messages"
          :key="message.id"
        >
          <p>{{ message.text }}</p>
          <pre v-if="Object.keys(message.context).length > 0">{{
            message.context
          }}</pre>
        </div>
        <template
          v-for="(field, fieldName) in method.config.fields"
          :key="fieldName"
        >
          <label v-if="field.type != 'hidden'" :for="field.name">{{
            field.name
          }}</label>
          <input :name="field.name" :type="field.type" :value="field.value" />
          <div
            class="error"
            v-for="message in field.messages"
            :key="message.id"
          >
            <p>{{ message.text }}</p>
            <pre>{{ message.context }}</pre>
          </div>
        </template>
        <input type="submit" value="Login" />
      </form>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";

export default defineComponent({
  name: "Login",
  components: {},
  data() {
    return {
      data: null
    };
  },
  watch: {
    $route: {
      immediate: true,
      handler(route) {
        const url = new URL("http://127.0.0.1:4433/self-service/login/flows");

        const params = { id: route.query.flow };
        url.search = new URLSearchParams(params).toString();

        fetch(url, { credentials: "include" }).then(async result => {
          this.data = await result.json();
        });
      }
    }
  }
});
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
