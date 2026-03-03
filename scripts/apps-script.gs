/**
 * =====================================================================
 *  apps-script.gs  —  Unción con Gloria · Registro Campaña 2026
 * =====================================================================
 *
 *  INSTRUCCIONES DE CONFIGURACIÓN:
 *
 *  1. Abrí Google Sheets en tu cuenta de Google.
 *  2. Creá una hoja nueva y llamala "Registros 2026" (o como quieras).
 *  3. Agregá estos encabezados en la fila 1 (columnas A-E):
 *       Timestamp | Nombre | Celular | Fecha | Hora
 *  4. En el menú: Extensiones → Apps Script
 *  5. Borrá el código por defecto y pegá TODO este archivo.
 *  6. Guardá (Ctrl+S) con el nombre "Registro Campaña".
 *  7. Hacé clic en "Implementar" (esquina superior derecha).
 *  8. Elegí "Nueva implementación":
 *       - Tipo:            Aplicación web
 *       - Descripción:     v1
 *       - Ejecutar como:   Yo (tu cuenta)
 *       - Quién accede:    Cualquier usuario
 *  9. Autorizá cuando Google lo pida.
 * 10. Copiá la URL que aparece (termina en /exec).
 * 11. Pegala en registro-campana.html en la variable SHEETS_URL.
 *
 *  ¡Listo! Cada registro del formulario aparecerá en tu hoja.
 * =====================================================================
 */

// ── Nombre de la hoja donde se guardan los datos ──────────────────────
var NOMBRE_HOJA = 'Registros 2026';

// ── POST: recibe un nuevo registro ────────────────────────────────────
function doPost(e) {
  try {
    var sheet = obtenerHoja();
    var data  = JSON.parse(e.postData.contents);

    sheet.appendRow([
      new Date(),          // Timestamp exacto del servidor
      data.nombre  || '',
      data.celular || '',
      data.fecha   || '',
      data.hora    || ''
    ]);

    return respuesta({ status: 'ok' });

  } catch (err) {
    return respuesta({ status: 'error', msg: err.toString() });
  }
}

// ── GET: devuelve el total de registros (para el contador en vivo) ────
function doGet(e) {
  try {
    var sheet = obtenerHoja();
    var total = Math.max(0, sheet.getLastRow() - 1); // -1 por la fila de encabezados
    return respuesta({ status: 'ok', total: total });
  } catch (err) {
    return respuesta({ status: 'error', msg: err.toString(), total: 0 });
  }
}

// ── Helpers internos ──────────────────────────────────────────────────
function obtenerHoja() {
  var ss    = SpreadsheetApp.getActiveSpreadsheet();
  var hoja  = ss.getSheetByName(NOMBRE_HOJA);

  // Si la hoja no existe todavía, la crea con encabezados
  if (!hoja) {
    hoja = ss.insertSheet(NOMBRE_HOJA);
    hoja.appendRow(['Timestamp', 'Nombre', 'Celular', 'Fecha', 'Hora']);
    hoja.setFrozenRows(1);

    // Formato visual de encabezados
    var rango = hoja.getRange(1, 1, 1, 5);
    rango.setBackground('#5C2D0A');
    rango.setFontColor('#FFFFFF');
    rango.setFontWeight('bold');
  }

  return hoja;
}

function respuesta(obj) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}
