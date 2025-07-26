```C#
// -----------------------------------------------------------------------
// <copyright file="RespawningTeam.cs" company="ExMod Team">
// Copyright (c) ExMod Team. All rights reserved.
// Licensed under the CC BY-SA 3.0 license.
// </copyright>
// -----------------------------------------------------------------------

using System.Collections.Generic;
using System.Reflection.Emit;
using Exiled.API.Features.Pools;
using HarmonyLib;
using Respawning.NamingRules;
using Respawning.Waves;

namespace ChinaBlueSkyRolePlugin.Modules.Essentials.Patches
{
    using static AccessTools;

    [HarmonyPatch(typeof(WaveSpawner), nameof(WaveSpawner.SpawnWave))]
    internal static class RespawnWavePatch
    {
        private static IEnumerable<CodeInstruction> Transpiler(IEnumerable<CodeInstruction> instructions, ILGenerator generator)
        {
            List<CodeInstruction> newInstructions = ListPool<CodeInstruction>.Pool.Get(instructions);

            int offset = -2;
            int index = newInstructions.FindIndex(instruction => instruction.Calls(Method(typeof(NamingRulesManager), nameof(NamingRulesManager.TryGetNamingRule)))) + offset;

            newInstructions.InsertRange(
                index,
                new[]
                {
                    new CodeInstruction(OpCodes.Ldloc_S, 2).MoveLabelsFrom(newInstructions[index]),

                    // maxWaveSize
                    new(OpCodes.Ldloc_3),

                    // num = 100
                    new(OpCodes.Ldc_I4, 100),  // 加载常数 100
                    new(OpCodes.Stloc_3),      // 将常数 100 存储到 maxWaveSize (即局部变量 3)
                });

            for (int z = 0; z < newInstructions.Count; z++)
                yield return newInstructions[z];

            ListPool<CodeInstruction>.Pool.Return(newInstructions);
        }
    }
}```