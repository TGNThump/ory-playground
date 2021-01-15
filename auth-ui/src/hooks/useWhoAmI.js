import { reactive, watchEffect } from "@vue/runtime-core";

export default function() {
  const ret = reactive({
    loading: false,
    data: null,
    error: null
  });

  watchEffect(() => {
    const url = new URL("http://127.0.0.1:4433/sessions/whoami");

    ret.loading = true;
    ret.data = null;
    ret.error = null;

    fetch(url, { credentials: "include" })
      .then(async result => {
        let json = await result.json();
        if ("error" in json) {
          ret.error = json.error;
          if (ret.error.details && ret.error.details.redirect_to) {
            window.location.href = ret.error.details.redirect_to;
          }
        } else {
          ret.data = json;
        }
      })
      .catch(async error => {
        ret.error = error;
      })
      .finally(() => {
        ret.loading = false;
      });
  });

  return ret;
}
