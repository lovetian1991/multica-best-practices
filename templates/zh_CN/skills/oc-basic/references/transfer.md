# 文件传输

## upload

上传文件到指定文件夹。请求通过 Multica 的固定 OpenContent facade 转发。

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `filePaths` | string | 是 | 本地文件路径；多个文件用竖线分隔 |
| `folderId` | string | 是 | 目标文件夹 ID、GUID 或浏览器地址 |
| `fileRemark` | string | 否 | 文件备注 |

```bash
$CLI upload filePaths=/path/to/file.pdf folderId=8616
$CLI upload 'filePaths=/path/a.txt|/path/b.md' folderId=8616
```

服务端默认限制上传为 20 MiB，并允许 `.md`、`.txt`、`.pdf`、`.png`、`.jpg`、`.jpeg`、`.gif`、`.webp`。后缀、空文件和实际内容类型由 Multica 服务端校验。

## download

下载普通文件、文件夹或 PDF 转换结果。

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `fileIds` | string | 否 | 文件 ID、GUID 或预览 URL 中的文件 ID；多个值用逗号分隔 |
| `url` | string | 否 | 文件预览地址，自动提取 `fileid` |
| `ver_id` | string | 否 | 文件版本 ID |
| `folderIds` | string | 否 | 文件夹 ID |
| `ispdfdownload` | boolean/string | 否 | 是否下载 PDF 转换结果 |
| `outputPath` | string | 否 | 输出目录或完整文件路径 |

`fileIds`、`url`、`ver_id` 和 `folderIds` 至少提供一个。传入 `url` 时不要同时传其它文件标识参数。

```bash
$CLI download fileIds=12345
$CLI download url="https://example.test/ecm?ctl=1#/preview?fileid=550e8400-e29b-41d4-a716-446655440000"
$CLI download fileIds=12345 outputPath=/tmp/downloads/
$CLI download fileIds=12345 ispdfdownload=true
```

下载响应由 facade 受限流式转发，不要把服务端返回的下载 URL 改写为任意外部地址，也不要绕过 facade 直连 OpenContent。

如果下载接口返回非 200，CLI 必须直接报错，并把响应内容原样作为错误信息展示；不要把它当成成功下载，也不要只输出通用失败。
