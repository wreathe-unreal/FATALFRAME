using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

#if UNITY_EDITOR
[InitializeOnLoad]
public static class HierarchyObjectColor
{
    public static HierarchyTagColors TagColors;

    static HierarchyObjectColor()
    {
        EditorApplication.hierarchyWindowItemOnGUI += HandleHierarchyWindowItemOnGUI;
        LoadTagColors();

        EditorApplication.update += OnEditorUpdate;
    }

    private static void LoadTagColors()
    {
        TagColors = Resources.Load<HierarchyTagColors>("HierarchyTagColors");
        if (TagColors == null)
        {
            Debug.LogError("HierarchyTagColors not found. Create it through Assets > Create > HierarchyObjectColor > Tag Colors");
        }
    }

    private static void HandleHierarchyWindowItemOnGUI(int instanceID, Rect selectionRect)
    {
        if (TagColors == null) return;

        var obj = EditorUtility.InstanceIDToObject(instanceID) as GameObject;
        if (obj == null) return;

        foreach (var tagColor in TagColors.TagColors)
        {
            if (obj.CompareTag(tagColor.Tag))
            {
                Rect bgRect = new Rect(selectionRect.x, selectionRect.y, selectionRect.width + 50, selectionRect.height);
                EditorGUI.DrawRect(bgRect, tagColor.Color);
                break;
            }
        }
    }

    private static void OnEditorUpdate()
    {
        EditorApplication.RepaintHierarchyWindow();
    }
}
#endif
