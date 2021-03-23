package expo.modules.structuredheaders

import android.content.Context

import org.unimodules.core.BasePackage
import org.unimodules.core.ExportedModule
import org.unimodules.core.ViewManager

class StructuredHeadersPackage : BasePackage() {
  override fun createExportedModules(context: Context): List<ExportedModule> {
    return listOf(StructuredHeadersModule(context) as ExportedModule)
  }

}
