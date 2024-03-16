package main

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func main() {
	dsn := "root:000000@tcp(ipaddr:3306)/users?charset=utf8mb4&collation=utf8mb4_unicode_ci&parseTime=True&loc=Local"

	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		fmt.Println(err)
	}

	sqlDB, err := db.DB()
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(10 * time.Second)

	type User struct {
		Username        string `json:"username"`
		Password        string `json:"password"`
		SelectedName    string `json:"name"` // 修改为前端传递的字段名
		SelectedImage   string `json:"image"`
		SelectedCpu     string `json:"cpu"`     // 修改为前端传递的字段名
		SelectedMemory  string `json:"memory"`  // 修改为前端传递的字段名
		SelectedStorage string `json:"storage"` // 修改为前端传递的字段名
	}
	db.AutoMigrate(&User{})

	r := gin.Default()

	// 添加 CORS 中间件处理跨域请求
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	})

	// 在主函数中添加路由用于获取所有虚拟机信息
	r.GET("/backend/virtualmachines", func(c *gin.Context) {
		var vms []User
		db.Find(&vms)
		c.JSON(http.StatusOK, vms)
	})

	// 修改 /backend/api POST 路由，在保存数据到数据库后返回成功状态
	r.POST("/backend/api", func(c *gin.Context) {
		var data User

		err := c.ShouldBindJSON(&data)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "Failed to bind JSON data",
			})
			return
		}

		// 打印接收到的数据进行调试
		fmt.Printf("Received data: %+v\n", data)

		// 保存数据到数据库
		result := db.Create(&data)
		if result.Error != nil {
			fmt.Println("Failed to save data to the database:", result.Error)
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "Failed to save data to the database",
			})
			return
		}

		// 创建文件并写入数据
		file, err := os.Create("num.txt")
		if err != nil {
			fmt.Println("Failed to create file:", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "Failed to create file",
			})
			return
		}
		defer file.Close()

		content := fmt.Sprintf("用户: %s\n主机名称: %s\n镜像选择: %s\nCPU数量: %s\n内存大小: %s\n硬盘大小: %s\n", data.Username, data.SelectedName, data.SelectedImage, data.SelectedCpu, data.SelectedMemory, data.SelectedStorage)
		_, err = file.WriteString(content)
		if err != nil {
			fmt.Println("Failed to write to file:", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "Failed to write to file",
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"code": "200",
		})
	})
	r.Run(":8080")
}
