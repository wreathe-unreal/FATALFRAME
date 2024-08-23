using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "HierarchyTagColors", menuName = "HierarchyObjectColor/Tag Colors", order = 0)]
public class HierarchyTagColors : ScriptableObject
{
    public List<TagColor> TagColors = new List<TagColor>();

    [System.Serializable]
    public class TagColor
    {
        public string Tag;
        public Color Color = Color.white;
    }
}
