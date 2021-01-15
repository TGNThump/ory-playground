<template>
  <div v-if="loading">Loading...</div>
  <pre v-else-if="error">{{ error }}</pre>
  <div v-else-if="data">
    <pre>{{ data.identity.traits }}</pre>
    <pre>{{ data.identity.verifiable_addresses }}</pre>
  </div>
</template>

<script>
import useWhoAmI from "@/hooks/useWhoAmI";

export default {
  setup() {
    return useWhoAmI();
  }
};
</script>
