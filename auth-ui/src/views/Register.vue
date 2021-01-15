<template>
  <KratosForm v-model="flow" />
</template>

<script>
import { useRoute } from "vue-router";
import useFlow from "@/hooks/useFlow";
import KratosForm from "@/components/KratosFlow";

export default {
  components: { KratosForm },
  setup() {
    const route = useRoute();
    const flow = useFlow("registration", route.query.flow);

    return { flow };
  }
};
</script>
