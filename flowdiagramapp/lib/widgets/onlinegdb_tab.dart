import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Tab that embeds OnlineGDB C compiler via WebView and auto-injects the
/// generated C source code using JavaScript (Ace Editor API).
class OnlineGdbTab extends StatefulWidget {
  /// The generated C code from the compiler pipeline.
  final String cCode;

  /// Whether compilation was successful (guards auto-injection).
  final bool compilationSuccess;

  const OnlineGdbTab({
    super.key,
    required this.cCode,
    required this.compilationSuccess,
  });

  @override
  State<OnlineGdbTab> createState() => OnlineGdbTabState();
}

class OnlineGdbTabState extends State<OnlineGdbTab>
    with AutomaticKeepAliveClientMixin {
  static const _url = 'https://www.onlinegdb.com/online_c_compiler';

  late final WebViewController _controller;

  bool _isLoading = true;
  bool _injected = false;
  String? _loadError;

  // ── Keep-alive so the WebView survives tab switches ─────────────────────
  @override
  bool get wantKeepAlive => true;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _injected = false;
            _loadError = null;
          }),
          onPageFinished: (_) async {
            await _hideOnlineGdbUI();
            if (widget.compilationSuccess && widget.cCode.isNotEmpty) {
              await _injectCode();
            }
            setState(() => _isLoading = false);
          },
          onWebResourceError: (err) {
            if (err.isForMainFrame != true) return;
            setState(() {
              _isLoading = false;
              _loadError = err.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  // ── UI cleanup ────────────────────────────────────────────────────────────

  static const _hideUiJs = r'''
(function() {
  /* ── CSS: baseline rules ── */
  var css =
    '.navbar,.navbar-default,nav.navbar{display:none!important}' +
    'footer,.footer{display:none!important}' +
    '#left-component{display:none!important}' +
    '#right-component{left:0!important;width:100%!important}' +
    '#ad_unit_bottom_wrapper,#ad_unit_bottom{display:none!important;height:0!important;overflow:hidden!important}' +
    '#ad_wrapper,#sidebar_adunit_wrapper,.right-sidebar{display:none!important}' +
    'iframe[id*="google_ads_iframe"]{display:none!important}' +
    '[class*="adsbygoogle"],[id*="div-gpt"]{display:none!important}' +
    'body{padding-top:0!important;margin-top:0!important}' +
    '#main-content,.main-content{margin-top:0!important;padding-top:0!important}';

  var s = document.createElement('style');
  s.innerHTML = css;
  document.head.appendChild(s);

  /* ── JS: force-hide helper ── */
  function killAd(el) {
    if (!el || !el.style) return;
    el.style.setProperty('display',    'none',   'important');
    el.style.setProperty('visibility', 'hidden', 'important');
    el.style.setProperty('height',     '0',      'important');
    el.style.setProperty('min-height', '0',      'important');
    el.style.setProperty('overflow',   'hidden', 'important');
  }

  var AD_IDS = [
    'ad_unit_bottom_wrapper',
    'ad_unit_bottom',
    'ad_wrapper',
    'sidebar_adunit_wrapper'
  ];

  /* Kill all known ad slots and attach a MutationObserver to each */
  function nuke() {
    AD_IDS.forEach(function(id) {
      var el = document.getElementById(id);
      if (!el) return;
      killAd(el);
      if (!el._adKilled) {
        el._adKilled = true;
        /* React instantly when jQuery .show() writes inline style */
        new MutationObserver(function() { killAd(el); })
          .observe(el, { attributes: true, attributeFilter: ['style','class'] });
      }
    });
    /* Google Ads iframes */
    document.querySelectorAll('iframe[id*="google_ads_iframe"]').forEach(function(f) {
      killAd(f); if (f.parentElement) killAd(f.parentElement);
    });
  }

  nuke();
  /* Poll every 500 ms — catches ads injected after page-load */
  setInterval(nuke, 500);
})();
''';

  Future<void> _hideOnlineGdbUI() async {
    try {
      await _controller.runJavaScript(_hideUiJs);
    } catch (_) {}
  }

  // ── Code injection ───────────────────────────────────────────────────────

  String _escapeForJs(String src) {
    return src
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t')
        .replaceAll('`', '\\`')
        .replaceAll('\$', '\\\$');
  }

  Future<void> _injectCode() async {
    if (_injected) return;

    final escapedCode = _escapeForJs(widget.cCode);

    final js = '''
(function() {
  var code = '$escapedCode';
  var attempts = 0;
  var maxAttempts = 60;

  function killBottomAd() {
    var adEl = document.getElementById('ad_unit_bottom_wrapper');
    if (adEl) {
      adEl.style.setProperty('display',    'none',   'important');
      adEl.style.setProperty('height',     '0',      'important');
      adEl.style.setProperty('min-height', '0',      'important');
      adEl.style.setProperty('overflow',   'hidden', 'important');
    }
  }

  var timer = setInterval(function() {
    attempts++;
    try {
      var aceEditor = ace.edit('editor_1');
      if (aceEditor && typeof aceEditor.setValue === 'function') {
        clearInterval(timer);

        // 1. Set code
        aceEditor.setValue(code, -1);

        // 2. Switch to Interactive Console
        //    input_method_handler('interactive') calls jQuery .show() on the
        //    bottom ad wrapper — so we immediately re-hide it after.
        if (typeof input_method_handler === 'function') {
          input_method_handler('interactive');
        } else {
          var radio = document.getElementById('input_method_interactive');
          if (radio) radio.click();
        }
        killBottomAd();

        // 3. Auto-run
        var runBtn = document.getElementById('control-btn-run');
        if (runBtn) runBtn.click();
      }
    } catch (e) {}
    if (attempts >= maxAttempts) clearInterval(timer);
  }, 250);
})();
''';

    try {
      await _controller.runJavaScript(js);
      setState(() => _injected = true);
    } catch (_) {}
  }

  Future<void> reinjectCode() async {
    setState(() => _injected = false);
    await _injectCode();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código inyectado en OnlineGDB'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildBody(isDark);
  }

  Widget _buildBody(bool isDark) {
    if (!widget.compilationSuccess) {
      return _buildCompileErrorState(isDark);
    }

    return Stack(
      children: [
        WebViewWidget(
          controller: _controller,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
        ),
        if (_isLoading) _buildLoadingOverlay(isDark),
        if (_loadError != null) _buildErrorOverlay(isDark),
      ],
    );
  }

  Widget _buildLoadingOverlay(bool isDark) {
    return Container(
      color: isDark
          ? const Color(0xFF0D1117).withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.88),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.deepOrange[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Cargando OnlineGDB…',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El código generado se insertará automáticamente',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(bool isDark) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red[900]!.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black38)],
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Error al cargar OnlineGDB. $_loadError',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _loadError = null;
                    _injected = false;
                  });
                  _controller.reload();
                },
                child: const Text('Reintentar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompileErrorState(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F5F5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Compilación con errores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Corrige los errores del compilador antes de\nejecutar en OnlineGDB.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            if (widget.cCode.isNotEmpty)
              FilledButton.icon(
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: widget.cCode)),
                style: FilledButton.styleFrom(backgroundColor: Colors.grey[800]),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copiar código C'),
              ),
          ],
        ),
      ),
    );
  }
}
