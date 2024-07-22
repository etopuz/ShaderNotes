using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class LightRotator : MonoBehaviour
{
    public float rotationSpeed = 1.0f;

    private void Awake()
    {
        var euler = transform.eulerAngles;
        transform.DORotate(new Vector3(0, 360, 0), rotationSpeed, RotateMode.WorldAxisAdd).SetEase(Ease.Linear).SetLoops(-1, LoopType.Incremental);
    }
    
}
