"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const experimental_1 = require("@pulumi/pulumi/provider/experimental");
const path = __importStar(require("path"));
// plugin/provider.ts
// process.stdout.write(`PULUMI_ENGINE=${String(process.env.PULUMI_ENGINE)}\n`);
// process.stdout.write(`PULUMI_MONITOR=${String(process.env.PULUMI_MONITOR)}\n`);
// process.stdout.write(`PULUMI_PROJECT=${String(process.env.PULUMI_PROJECT)}\n`);
// process.stdout.write(`PULUMI_STACK=${String(process.env.PULUMI_STACK)}\n`);
// IMPORTANT: ensure provider packages used by your components are loaded.
require("@pulumi/azure-native");
const StorageAccountWithContainer_1 = require("../components/azure-storage/StorageAccountWithContainer");
(0, experimental_1.componentProviderHost)({
    name: "pulumi-components-demo",
    // Point the analyzer at the package root that contains tsconfig + sources.
    dirname: path.resolve(__dirname, "..", ".."),
    components: [StorageAccountWithContainer_1.StorageAccountWithContainer],
});
//# sourceMappingURL=provider.js.map