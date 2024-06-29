using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Hole : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.TryGetComponent(out DroppableObject dropabbleObject))
        {
            dropabbleObject.Drop(transform);
        }
    }
}
