/* Hero — three variants selectable via Tweaks */
const { useState, useEffect, useRef } = React;

function useTypeLoop(text, { typeMs = 70, eraseMs = 40, holdMs = 1400, gapMs = 500 } = {}) {
  const [out, setOut] = useState("");
  useEffect(() => {
    let cancelled = false;
    let timer;
    const run = async () => {
      while (!cancelled) {
        // type
        for (let i = 1; i <= text.length; i++) {
          if (cancelled) return;
          setOut(text.slice(0, i));
          await new Promise(r => { timer = setTimeout(r, typeMs); });
        }
        // hold
        await new Promise(r => { timer = setTimeout(r, holdMs); });
        if (cancelled) return;
        // erase
        for (let i = text.length - 1; i >= 0; i--) {
          if (cancelled) return;
          setOut(text.slice(0, i));
          await new Promise(r => { timer = setTimeout(r, eraseMs); });
        }
        // gap
        await new Promise(r => { timer = setTimeout(r, gapMs); });
      }
    };
    run();
    return () => { cancelled = true; clearTimeout(timer); };
  }, [text, typeMs, eraseMs, holdMs, gapMs]);
  return out;
}

const HeroBadge = ({ text }) => (
  <span className="hero-eyebrow">
    <span className="dot"></span>
    {text}
  </span>
);

const HeroCopy = ({ t }) => {
  const h = t.hero;
  const typed = useTypeLoop("AHK Manager", { typeMs: 70, eraseMs: 40, holdMs: 1400, gapMs: 500 });
  return (
    <div>
      <HeroBadge text={h.badge} />
      <h1 className="hero-title">
        <span className="accent">{typed}</span><span className="hero-cursor"></span>
      </h1>
      <p className="hero-lead">{h.lead}</p>
      <div className="hero-cta">
        <a href="https://github.com/Lazy-World/wf-macro-loader/releases" className="btn btn-primary btn-lg">
          <Ico.ArrowDownToLine size={16} /> {h.ctaPrimary}
        </a>
        <a href="https://github.com/Lazy-World/wf-macro-loader" className="btn btn-outline btn-lg">
          <Ico.Github size={16} /> {h.ctaSecondary}
        </a>
      </div>
      <div className="hero-meta">
        <div className="hero-meta-item"><div className="label">{h.meta1Label}</div><div className="value">{h.meta1Value}</div></div>
        <div className="hero-meta-item"><div className="label">{h.meta2Label}</div><div className="value">{h.meta2Value}</div></div>
        <div className="hero-meta-item"><div className="label">{h.meta3Label}</div><div className="value">{h.meta3Value}</div></div>
        <div className="hero-meta-item"><div className="label">{h.meta4Label}</div><div className="value">{h.meta4Value}</div></div>
      </div>
    </div>
  );
};

const HeroArtMascot = () => (
  <div className="hero-art">
    <div className="hero-art-grid"></div>
    <div className="hero-art-corner tl">cat.svg</div>
    <div className="hero-art-corner tr">1067 × 1068</div>
    <div className="hero-art-corner bl">v0.4.2</div>
    <div className="hero-art-corner br">cat is cat</div>
    <img src="assets/cat.svg" alt="" className="hero-art-cat" />
  </div>
);

const HeroArtTerminal = ({ lang }) => {
  const lines = lang === "ru" ? [
    { p: "$", t: " ahk-manager --start" },
    { p: ">", t: " проверка обновлений..." , dim: true },
    { p: ">", t: " репозиторий wf-macro: ", suf: "up to date", ok: true },
    { p: ">", t: " скриптов в каталоге: ", suf: "42", accent: true },
    { p: ">", t: " биндов перезаписано: ", suf: "6", accent: true },
    { p: "✓", t: " готов. нажмите клавишу.", ok: true, bold: true }
  ] : [
    { p: "$", t: " ahk-manager --start" },
    { p: ">", t: " checking for updates..." , dim: true },
    { p: ">", t: " wf-macro repo: ", suf: "up to date", ok: true },
    { p: ">", t: " scripts in catalog: ", suf: "42", accent: true },
    { p: ">", t: " binds rewritten: ", suf: "6", accent: true },
    { p: "✓", t: " ready. press a key.", ok: true, bold: true }
  ];
  const [shown, setShown] = useState(0);
  useEffect(() => {
    setShown(0);
    const id = setInterval(() => setShown(s => s < lines.length ? s + 1 : s), 320);
    return () => clearInterval(id);
  }, [lang]);
  return (
    <div className="hero-terminal">
      <div className="hero-terminal-head">
        <span className="hero-terminal-dot"></span>
        <span className="hero-terminal-dot"></span>
        <span className="hero-terminal-dot"></span>
        <span className="hero-terminal-title">~/ahk-manager — bash</span>
      </div>
      <div className="hero-terminal-body">
        {lines.slice(0, shown).map((l, i) => (
          <div key={i} className="hero-terminal-line">
            <span className="prompt">{l.p}</span>
            <span className={l.dim ? "dim" : l.ok && !l.suf ? "ok" : ""} style={l.bold ? { fontWeight: 600 } : null}>{l.t}</span>
            {l.suf && <span className={l.ok ? "ok" : l.accent ? "accent" : ""}>{l.suf}</span>}
          </div>
        ))}
        {shown < lines.length && <div className="hero-terminal-line"><span className="hero-cursor" style={{ background: "currentColor" }}></span></div>}
      </div>
    </div>
  );
};

const HeroArtMinimal = () => (
  <div className="hero-minimal">
    <img src="assets/cat.svg" alt="" className="hero-minimal-cat" />
    <div className="hero-minimal-stamp">
      <div className="row"><span>cercony</span><span>·</span><span>2026</span></div>
      <div className="row"><span>v0.4.2</span><span>·</span><span>mit</span></div>
    </div>
  </div>
);

const Hero = ({ t, variant, lang }) => (
  <section className="hero">
    <div className="hero-grid">
      <HeroCopy t={t} />
      {variant === "mascot" && <HeroArtMascot />}
      {variant === "terminal" && <HeroArtTerminal lang={lang} />}
      {variant === "minimal" && <HeroArtMinimal />}
    </div>
  </section>
);

window.Hero = Hero;
