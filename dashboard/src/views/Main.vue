<!-- eslint-disable vue/multi-word-component-names -->
<template>
  <div>
    <h1>EtStack</h1>
    <p>欢迎登陆：{{ username }}</p>
    <label for="name">虚拟机名称:</label>
    <input type="text" v-model="selectedName" />
    <br />
    <label for="image">选择镜像：</label>
    <select v-model="selectedImage">
      <option value="">
      </option>
      <!-- 添加更多镜像选项 -->
    </select>
    <br />
    <label for="memory">CPU数量(单位:个):</label>
    <input type="text" v-model="selectedCpu" />
    <br />
    <label for="memory">内存大小(单位:MB):</label>
    <input type="text" v-model="selectedMemory" />
    <br />
    <label for="storage">硬盘大小(单位:GB):</label>
    <input type="text" v-model="selectedStorage" />
    <br />
    <button @click="sendData">提交</button>

    <table v-if="virtualMachines.length > 0">
      <thead>
        <tr>
          <th>用户</th>
          <th>虚拟机名称</th>
          <th>镜像类型</th>
          <th>CPU数量</th>
          <th>内存大小</th>
          <th>硬盘大小</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="vm in virtualMachines" :key="vm.id">
          <td>{{ vm.username }}</td>
          <td>{{ vm.name }}</td>
          <td>{{ vm.image }}</td>
          <td>{{ vm.cpu }}</td>
          <td>{{ vm.memory }}</td>
          <td>{{ vm.storage }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  data() {
    return {
      username: "",
      selectedName: "",
      selectedImage: "",
      selectedCpu: "",
      selectedMemory: "",
      selectedStorage: "",
      virtualMachines: [],
    };
  },
  mounted() {
    // 模拟从路由参数获取用户名
    this.username = this.$route.query.username;
    this.getVirtualMachines(); // 页面加载时自动获取虚拟机信息
  },
  methods: {
    sendData() {
      const newVirtualMachine = {
        username: this.username, // 添加用户名字段
        name: this.selectedName,
        image: this.selectedImage,
        cpu: this.selectedCpu,
        memory: this.selectedMemory,
        storage: this.selectedStorage,
      };

      fetch("http://ipaddr:8080/backend/api", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(newVirtualMachine),
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.code === "200") {
            this.getVirtualMachines(); // 数据保存成功后刷新列表
            this.selectedName = "";
            this.selectedImage = "";
            this.selectedCpu = "";
            this.selectedMemory = "";
            this.selectedStorage = "";
          }
        })
        .catch((error) => {
          console.error("Error:", error);
        });
    },

    getVirtualMachines() {
      fetch("http://ipaddr:8080/backend/virtualmachines")
        .then((response) => response.json())
        .then((data) => {
          this.virtualMachines = data;
        })
        .catch((error) => {
          console.error("Error:", error);
        });
    },
  },
};
</script>
