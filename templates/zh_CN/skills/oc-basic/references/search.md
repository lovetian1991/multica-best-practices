# 目录浏览与基础查询

## file-list

浏览指定文件夹的直接子项，默认只读取第一页。

| 参数 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `folderId` | string | 否 | 文件夹 ID、GUID 或浏览器地址；默认 `1`，`2` 表示个人库根目录 |
| `pageNum` | number | 否 | 页码，默认 `1` |
| `pageSize` | number | 否 | 每页数量，默认 `20` |

```bash
$CLI file-list
$CLI file-list folderId=309
$CLI file-list folderId=2 pageNum=1 pageSize=20
```

返回 `folderId`、`folderName`、`total` 和 `items`。每个 item 至少包含 `type`、`id`、`name`；文件可能包含 `size` 和 `path`。

返回结果保持原始 JSON 结构，不额外构造 `columns` 或 `url`。

如果返回 JSON 不完整或缺少 `items`，先降低 `pageSize`，不要猜测缺失字段。

## file-info

按文件 ID、GUID 或预览地址查询文件信息。

| 参数 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `fileId` | string | 是 | 文件 ID、GUID 或包含 `fileid` 参数的预览地址 |

```bash
$CLI file-info fileId=150120
$CLI file-info fileId=5a2a7aeb-b9fa-4d52-a6e7-4f0899932e7b
$CLI file-info fileId="https://example.test/ecm?ctl=1#/preview?fileid=5a2a7aeb-b9fa-4d52-a6e7-4f0899932e7b"
```

如果返回多个候选，不要自动选择。文件 ID/GUID 的解析由受控服务完成。

## folder-info

按文件夹 ID、GUID 或浏览器地址查询文件夹信息。

| 参数 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `folderId` | string | 是 | 文件夹 ID、GUID 或包含 `id` 参数的浏览器地址 |

```bash
$CLI folder-info folderId=309
$CLI folder-info folderId=550e8400-e29b-41d4-a716-446655440000
$CLI folder-info folderId="https://example.test/ecm#/index?id=enterprise_550e8400-e29b-41d4-a716-446655440000"
```
