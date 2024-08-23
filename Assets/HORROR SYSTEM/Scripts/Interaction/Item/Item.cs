using UnityEngine;

public class Item : MonoBehaviour
{
    public virtual void ActivateObject()
    {
        //Starting an action
    }

    protected void DestroyObject(float destroyTimer)
    {
        Destroy(this.gameObject, destroyTimer);
    }
}
