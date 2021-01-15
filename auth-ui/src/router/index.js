import { createRouter, createWebHistory } from "vue-router";
import Home from "../views/Home.vue";

const routes = [
  {
    path: "/",
    name: "Home",
    component: Home
  },
  {
    path: "/auth/login",
    name: "Login",
    component: () =>
      import(/* webpackChunkName: "login" */ "../views/Login.vue"),
    beforeEnter: (to, from, next) => {
      if ("flow" in to.query) next();
      else {
        window.location.href =
          "http://127.0.0.1:4433/self-service/login/browser";
      }
    }
  },
  {
    path: "/auth/register",
    name: "Register",
    component: () =>
      import(/* webpackChunkName: "login" */ "../views/Register.vue"),
    beforeEnter: (to, from, next) => {
      if ("flow" in to.query) next();
      else {
        window.location.href =
          "http://127.0.0.1:4433/self-service/registration/browser";
      }
    }
  },
  {
    path: "/auth/recovery",
    name: "Recovery",
    component: () =>
      import(/* webpackChunkName: "login" */ "../views/Recovery.vue"),
    beforeEnter: (to, from, next) => {
      if ("flow" in to.query) next();
      else {
        window.location.href =
          "http://127.0.0.1:4433/self-service/recovery/browser";
      }
    }
  },
  {
    path: "/settings",
    name: "Settings",
    component: () =>
      import(/* webpackChunkName: "login" */ "../views/Settings.vue"),
    beforeEnter: (to, from, next) => {
      if ("flow" in to.query) next();
      else {
        window.location.href =
          "http://127.0.0.1:4433/self-service/settings/browser";
      }
    }
  },
  {
    path: "/auth/logout",
    name: "Logout",
    redirect: () => {
      window.location.href =
        "http://127.0.0.1:4433/self-service/browser/flows/logout";
      return "no";
    }
  }
];

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
});

export default router;
