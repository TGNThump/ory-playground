<template>
  <div id="nav">
    <router-link to="/">Home</router-link> |
    <router-link to="/auth/login">Login</router-link> |
    <router-link to="/auth/register">Register</router-link> |
    <router-link to="/auth/recovery">Recovery</router-link> |
    <router-link to="/auth/logout">Logout</router-link> |
    <router-link to="/settings">Settings</router-link>
  </div>
  <router-view />
</template>

<style lang="scss"></style>
