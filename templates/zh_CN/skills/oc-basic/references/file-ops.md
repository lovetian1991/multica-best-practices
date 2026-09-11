# 文件夹创建

`create-folder` 命令用于在指定父文件夹下新建文件夹。

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `name` | string | 是 | 文件夹名称 |
| `parentFolderId` | string | 是 | 父文件夹 ID、GUID 或浏览器地址 |
| `remark` | string | 否 | 备注 |
| `code` | string | 否 | 文件夹编号 |

```bash
$CLI create-folder name=设计文档 parentFolderId=309
$CLI create-folder name=测试报告 parentFolderId=309 remark=Q1测试
```

命令会先规范化父文件夹标识，再通过 Multica facade 调用固定的创建文件夹接口。
