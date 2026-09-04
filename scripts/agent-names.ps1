# Canonical Multica Agent display names.
# Change this block when a production Agent is renamed. Role IDs used by
# prompts, Skills, and Squad definitions remain stable and are not display names.
$standardAgentNames = [ordered]@{
    Architect         = '技术架构师'
    ArchReviewer      = '架构评审'
    BackendDev        = '后台开发专家'
    BackendReviewer   = '后端评审'
    Designer          = 'UI/UE设计师'
    DesignReviewer    = '设计评审'
    DevOps            = '部署运维专家'
    DevelopmentLeader = '研发总监'
    FrontendDev       = '前端开发专家'
    FrontendReviewer  = '前端评审'
    Leader            = '通用小队负责人'
    ProductLeader     = '产品总监'
    ProductManager    = '产品经理'
    ProductReviewer   = '产品评审'
    Reviewer          = '业务评审'
    Tester            = '测试专家'
    TestReviewer      = '测试评审'
}

# Names that existed in older workspaces. Keep these only for lookup so an
# existing object can be reused during migration; never create new Agents from
# these aliases.
$legacyAgentNames = @{
    Designer = @('界面与交互设计师')
    DevOps = @('运维工程师')
}
