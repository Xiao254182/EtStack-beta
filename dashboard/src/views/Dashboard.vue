<!-- eslint-disable vue/multi-word-component-names -->
<template>
  <div>
    <p>用户名</p>
    <input type="text" v-model="user" />
    <p>密码</p>
    <input type="text" v-model="pass" />
    <p></p>
    <br />
    <button @click="sendDataToBackend">登入</button>
    <p v-if="responseMessage">{{ responseMessage }}</p>
  </div>
</template>

<script>
import axios from "axios";

export default {
  data() {
    return {
      user: "",
      pass: "", // 输入框中的内容将绑定到该变量
      responseMessage: "", // 用于显示后端返回的消息
    };
  },
  methods: {
    sendDataToBackend() {
      const data = {
        username: this.user, // 获取用户名输入框中的内容
        password: this.pass, // 获取密码输入框中的内容
      };

      axios
        .post("http://ipaddr:8080/backend/api", data)
        .then((response) => {
          // 处理后端返回的响应
          if (response.status === 200) {
            this.responseMessage = response.data.message;
            // 可以根据后端返回的信息进行页面跳转
            this.$router.push({
              path: "/main",
              query: { username: this.user },
            });
          }
        })
        .catch((error) => {
          this.responseMessage = "数据发送失败：" + error.message;
        });
    },
  },
};
</script>
