using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor.ShaderGraph;
using UnityEngine;

[Title("CustomNode", "NormalBlend")]
public class NormalBlendNode : CodeFunctionNode
{
    public NormalBlendNode()
    {
        name = "NormalBlend";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("NormalBlend", BindingFlags.Static | BindingFlags.NonPublic);
    }

    private static string NormalBlend(
        [Slot(0, Binding.None)]Vector3 A,
        [Slot(1, Binding.None)]Vector3 B,
        [Slot(2, Binding.None)]out Vector1 Out)
    {
        return @"
        {
            Out = A + B;
        }";
    }
}
