using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SM_RaycastMouse : MonoBehaviour
{
    public Material sphericalMask;
    
    private Camera mainCamera;
    private Ray ray;
    private RaycastHit rayHit;
    private Vector3 mousePos;
    private Vector3 smoothPoint;

    public float radius;
    public float softness;
    public float smoothSpeed;
    public float scaleFactor;

    // Start is called before the first frame update
    void Start()
    {
        mainCamera = Camera.main;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.UpArrow))
        {
            radius += scaleFactor * Time.deltaTime;
        }

        if (Input.GetKey(KeyCode.DownArrow))
        {
            radius -= scaleFactor * Time.deltaTime;
        }

        if (Input.GetKey(KeyCode.LeftArrow))
        {
            softness += scaleFactor * Time.deltaTime;
        }

        if (Input.GetKey(KeyCode.RightArrow))
        {
            softness -= scaleFactor * Time.deltaTime;
        }

        radius = Mathf.Clamp(radius, 0, 4);
        softness = Mathf.Clamp(softness, -4, 4);

        mousePos = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 0);
        ray = mainCamera.ScreenPointToRay(mousePos);

        if (Physics.Raycast(ray, out rayHit))
        {
            smoothPoint = Vector3.MoveTowards(smoothPoint, rayHit.point, smoothSpeed * Time.deltaTime);
            Vector4 pos = new Vector4(smoothPoint.x, smoothPoint.y, smoothPoint.z, 0);
            sphericalMask.SetVector("_Position", pos);
        }

        sphericalMask.SetFloat("_Radius", radius);
        sphericalMask.SetFloat("_Softness", softness);
    }
}
