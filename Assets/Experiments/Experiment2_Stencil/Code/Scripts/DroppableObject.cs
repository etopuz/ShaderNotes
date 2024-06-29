using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class DroppableObject : MonoBehaviour
{
    Rigidbody rb;
    public float dropForce = 1000;
    public ForceMode dropForceMode;
    public void Awake()
    {
        rb = GetComponent<Rigidbody>();
    }

    public void Drop(Transform pos)
    {
        rb.AddForceAtPosition(new Vector3(0,-dropForce,0), pos.position, dropForceMode);
    }
}
