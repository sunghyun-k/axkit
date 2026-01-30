import ApplicationServices

/// 자주 사용되는 역할 상수
public enum AXRole: Sendable {
    // MARK: - 기본 역할

    public static let application = kAXApplicationRole as String
    public static let window = kAXWindowRole as String
    public static let sheet = kAXSheetRole as String
    public static let drawer = kAXDrawerRole as String

    // MARK: - 컨트롤

    public static let button = kAXButtonRole as String
    public static let radioButton = kAXRadioButtonRole as String
    public static let checkBox = kAXCheckBoxRole as String
    public static let popUpButton = kAXPopUpButtonRole as String
    public static let menuButton = kAXMenuButtonRole as String
    public static let tabGroup = kAXTabGroupRole as String
    public static let slider = kAXSliderRole as String
    public static let incrementor = kAXIncrementorRole as String
    public static let busyIndicator = kAXBusyIndicatorRole as String
    public static let progressIndicator = kAXProgressIndicatorRole as String
    public static let relevanceIndicator = kAXRelevanceIndicatorRole as String

    // MARK: - 텍스트

    public static let textField = kAXTextFieldRole as String
    public static let textArea = kAXTextAreaRole as String
    public static let staticText = kAXStaticTextRole as String

    // MARK: - 메뉴

    public static let menuBar = kAXMenuBarRole as String
    public static let menuBarItem = kAXMenuBarItemRole as String
    public static let menu = kAXMenuRole as String
    public static let menuItem = kAXMenuItemRole as String

    // MARK: - 테이블/리스트

    public static let table = kAXTableRole as String
    public static let outline = kAXOutlineRole as String
    public static let browser = kAXBrowserRole as String
    public static let list = kAXListRole as String
    public static let row = kAXRowRole as String
    public static let column = kAXColumnRole as String
    public static let cell = kAXCellRole as String

    // MARK: - 스크롤

    public static let scrollArea = kAXScrollAreaRole as String
    public static let scrollBar = kAXScrollBarRole as String

    // MARK: - 컨테이너

    public static let group = kAXGroupRole as String
    public static let splitGroup = kAXSplitGroupRole as String
    public static let splitter = kAXSplitterRole as String
    public static let toolbar = kAXToolbarRole as String

    // MARK: - 이미지/미디어

    public static let image = kAXImageRole as String
    public static let valueIndicator = kAXValueIndicatorRole as String

    // MARK: - 링크

    public static let link = "AXLink"

    // MARK: - 웹

    public static let webArea = "AXWebArea"

    // MARK: - 기타

    public static let unknown = kAXUnknownRole as String
    public static let comboBox = kAXComboBoxRole as String
    public static let disclosureTriangle = kAXDisclosureTriangleRole as String
    public static let colorWell = kAXColorWellRole as String
    public static let growArea = kAXGrowAreaRole as String
    public static let handle = kAXHandleRole as String
    public static let helpTag = kAXHelpTagRole as String
    public static let matte = kAXMatteRole as String
    public static let ruler = kAXRulerRole as String
    public static let rulerMarker = kAXRulerMarkerRole as String
    public static let levelIndicator = kAXLevelIndicatorRole as String
}

/// 자주 사용되는 액션 상수
public enum AXAction: Sendable {
    public static let press = kAXPressAction as String
    public static let increment = kAXIncrementAction as String
    public static let decrement = kAXDecrementAction as String
    public static let confirm = kAXConfirmAction as String
    public static let cancel = kAXCancelAction as String
    public static let showMenu = kAXShowMenuAction as String
    public static let pick = kAXPickAction as String
    public static let raise = kAXRaiseAction as String
    public static let showAlternateUI = kAXShowAlternateUIAction as String
    public static let showDefaultUI = kAXShowDefaultUIAction as String
}

/// 자주 사용되는 속성 상수
public enum AXAttribute: Sendable {
    // MARK: - 기본 속성

    public static let role = kAXRoleAttribute as String
    public static let subrole = kAXSubroleAttribute as String
    public static let roleDescription = kAXRoleDescriptionAttribute as String
    public static let title = kAXTitleAttribute as String
    public static let axDescription = kAXDescriptionAttribute as String
    public static let help = kAXHelpAttribute as String
    public static let value = kAXValueAttribute as String
    public static let identifier = kAXIdentifierAttribute as String

    // MARK: - 상태

    public static let enabled = kAXEnabledAttribute as String
    public static let focused = kAXFocusedAttribute as String
    public static let selected = kAXSelectedAttribute as String

    // MARK: - 위치/크기

    public static let position = kAXPositionAttribute as String
    public static let size = kAXSizeAttribute as String
    public static let frame = "AXFrame"

    // MARK: - 계층 구조

    public static let parent = kAXParentAttribute as String
    public static let children = kAXChildrenAttribute as String
    public static let topLevelUIElement = kAXTopLevelUIElementAttribute as String

    // MARK: - 창 관련

    public static let windows = kAXWindowsAttribute as String
    public static let mainWindow = kAXMainWindowAttribute as String
    public static let focusedWindow = kAXFocusedWindowAttribute as String
    public static let focusedUIElement = kAXFocusedUIElementAttribute as String

    // MARK: - 메뉴

    public static let menuBar = kAXMenuBarAttribute as String

    // MARK: - 애플리케이션

    public static let frontmost = kAXFrontmostAttribute as String
    public static let hidden = kAXHiddenAttribute as String

    // MARK: - 텍스트

    public static let numberOfCharacters = kAXNumberOfCharactersAttribute as String
    public static let selectedText = kAXSelectedTextAttribute as String
    public static let selectedTextRange = kAXSelectedTextRangeAttribute as String
    public static let visibleCharacterRange = kAXVisibleCharacterRangeAttribute as String
    public static let insertionPointLineNumber = kAXInsertionPointLineNumberAttribute as String
}

/// 자주 사용되는 서브롤 상수
public enum AXSubrole: Sendable {
    public static let closeButton = kAXCloseButtonSubrole as String
    public static let minimizeButton = kAXMinimizeButtonSubrole as String
    public static let zoomButton = kAXZoomButtonSubrole as String
    public static let toolbarButton = kAXToolbarButtonSubrole as String
    public static let fullScreenButton = kAXFullScreenButtonSubrole as String
    public static let secureTextField = kAXSecureTextFieldSubrole as String
    public static let tableRow = kAXTableRowSubrole as String
    public static let outlineRow = kAXOutlineRowSubrole as String
    public static let unknown = kAXUnknownSubrole as String
    public static let standardWindow = kAXStandardWindowSubrole as String
    public static let dialog = kAXDialogSubrole as String
    public static let systemDialog = kAXSystemDialogSubrole as String
    public static let floatingWindow = kAXFloatingWindowSubrole as String
    public static let systemFloatingWindow = kAXSystemFloatingWindowSubrole as String
    public static let incrementArrow = kAXIncrementArrowSubrole as String
    public static let decrementArrow = kAXDecrementArrowSubrole as String
    public static let incrementPage = kAXIncrementPageSubrole as String
    public static let decrementPage = kAXDecrementPageSubrole as String
    public static let searchField = kAXSearchFieldSubrole as String
    public static let textAttachment = "AXTextAttachment"
    public static let textLink = "AXTextLink"
    public static let timeline = kAXTimelineSubrole as String
    public static let sortButton = kAXSortButtonSubrole as String
    public static let ratingIndicator = kAXRatingIndicatorSubrole as String
    public static let contentList = kAXContentListSubrole as String
    public static let definitionList = kAXDefinitionListSubrole as String
    public static let toggle = kAXToggleSubrole as String
    public static let switchSubrole = kAXSwitchSubrole as String
    public static let descriptionList = kAXDescriptionListSubrole as String
}
