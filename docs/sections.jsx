/* Sections: What, Features, Install, FAQ, Contribute, Footer */

const { useState: useState2 } = React;

const SectionHeader = ({ eyebrow, title, lead }) => (
  <div className="reveal">
    <div className="section-eyebrow">{eyebrow}</div>
    <h2 className="section-title">{title}</h2>
    {lead && <p className="section-lead">{lead}</p>}
  </div>
);

/* ===== What ===== */
const What = ({ t }) => (
  <section className="section" id="what">
    <SectionHeader eyebrow={t.what.eyebrow} title={t.what.title} lead={t.what.lead} />
  </section>
);

/* ===== Features grid ===== */
const FEATURE_ICONS = [
  (p) => <Ico.Download {...p} />,
  (p) => <Ico.Zap {...p} />,
  (p) => <Ico.Keyboard {...p} />,
  (p) => <Ico.Library {...p} />,
  (p) => <Ico.Box {...p} />,
  (p) => <Ico.Lock {...p} />
];

const Features = ({ t }) => (
  <section className="section" id="features">
    <SectionHeader eyebrow={t.features.eyebrow} title={t.features.title} />
    <div className="reveal" style={{ marginTop: 32 }}>
      <div className="features">
        {t.features.items.map((f, i) => {
          const IconC = FEATURE_ICONS[i] || FEATURE_ICONS[0];
          return (
            <div key={i} className="feature">
              <div className="feature-icon"><IconC size={18} /></div>
              <h3 className="feature-title">{f.title}</h3>
              <p className="feature-desc">{f.desc}</p>
              <div className="feature-meta">{f.meta}</div>
            </div>
          );
        })}
      </div>
    </div>
  </section>
);

/* ===== Install ===== */
const CopyBtn = ({ text }) => {
  const [ok, setOk] = useState2(false);
  const click = () => {
    navigator.clipboard?.writeText(text);
    setOk(true);
    setTimeout(() => setOk(false), 1400);
  };
  return (
    <button className={`step-copy ${ok ? "ok" : ""}`} onClick={click} aria-label="Copy">
      {ok ? <Ico.Check size={14} /> : <Ico.Copy size={14} />}
    </button>
  );
};

const Install = ({ t }) => (
  <section className="section" id="install">
    <SectionHeader eyebrow={t.install.eyebrow} title={t.install.title} />
    <div className="reveal install" style={{ marginTop: 32 }}>
      {t.install.steps.map((s, i) => (
        <div key={i} className="step">
          <div className="step-num">step {String(i + 1).padStart(2, "0")}</div>
          <h3 className="step-title">{s.title}</h3>
          <p className="step-desc">{s.desc}</p>
          <div className="step-code">
            <code>{s.code}</code>
            <CopyBtn text={s.code} />
          </div>
        </div>
      ))}
    </div>
  </section>
);

/* ===== FAQ ===== */
const FAQ = ({ t }) => {
  const [open, setOpen] = useState2(0);
  return (
    <section className="section" id="faq">
      <SectionHeader eyebrow={t.faq.eyebrow} title={t.faq.title} />
      <div className="reveal faq" style={{ marginTop: 32 }}>
        {t.faq.items.map((it, i) => (
          <div key={i} className={`faq-item ${open === i ? "open" : ""}`}>
            <button className="faq-q" onClick={() => setOpen(open === i ? -1 : i)}>
              <span>{it.q}</span>
              <span className="faq-q-icon"><Ico.Plus size={14} /></span>
            </button>
            <div className="faq-a">{it.a}</div>
          </div>
        ))}
      </div>
    </section>
  );
};

/* ===== Contribute ===== */
const ScriptExample = () => (
  <>
    <div><span className="com">#Requires</span> <span className="kw">AutoHotkey</span> <span className="str">"v2.0"</span></div>
    <div>&nbsp;</div>
    <div><span className="com">; load config beside the script</span></div>
    <div>cfg := <span className="kw">FileRead</span>(<span className="str">A_ScriptDir "\cfg\my_macro.json"</span>)</div>
    <div>g := json_load(&cfg)</div>
    <div>&nbsp;</div>
    <div><span className="com">; bind hotkeys from cfg.hk</span></div>
    <div><span className="kw">for</span> fn, hk <span className="kw">in</span> g[<span className="str">"hk"</span>] {"{"}</div>
    <div>&nbsp;&nbsp;<span className="kw">Hotkey</span>(<span className="str">"*"</span> . hk[<span className="str">"key"</span>], %fn%)</div>
    <div>{"}"}</div>
    <div><span className="kw">return</span></div>
    <div>&nbsp;</div>
    <div>testDelay(*) {"{"}</div>
    <div>&nbsp;&nbsp;<span className="kw">if</span> !g[<span className="str">"val"</span>][<span className="str">"enableTest"</span>][<span className="str">"val"</span>]</div>
    <div>&nbsp;&nbsp;&nbsp;&nbsp;<span className="kw">return</span></div>
    <div>&nbsp;&nbsp;<span className="kw">SendInput</span> <span className="str">{`"{" g["keys"]["tab"] "}"`}</span></div>
    <div>&nbsp;&nbsp;<span className="kw">Sleep</span> g[<span className="str">"val"</span>][<span className="str">"sleep1"</span>][<span className="str">"val"</span>]</div>
    <div>{"}"}</div>
    <div>&nbsp;</div>
    <div>*<span className="kw">Insert</span>::<span className="kw">Reload</span></div>
    <div>*<span className="kw">Del</span>::<span className="kw">ExitApp</span></div>
  </>
);

const ConfigExample = () => (
  <>
    <div>{"{"}</div>
    <div>&nbsp;&nbsp;<span className="str">"$version"</span>: <span className="kw">1</span>,</div>
    <div>&nbsp;&nbsp;<span className="str">"hk"</span>: {"{"}</div>
    <div>&nbsp;&nbsp;&nbsp;&nbsp;<span className="str">"testDelay"</span>: {"{"}</div>
    <div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span className="str">"key"</span>: <span className="str">"F1"</span>,</div>
    <div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span className="str">"description"</span>: <span className="str">"Test delay"</span>,</div>
    <div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span className="str">"tooltip"</span>: <span className="str">"Measures delay"</span></div>
    <div>&nbsp;&nbsp;&nbsp;&nbsp;{"}"}</div>
    <div>&nbsp;&nbsp;{"}"},</div>
    <div>&nbsp;&nbsp;<span className="str">"val"</span>: {"{"}</div>
    <div>&nbsp;&nbsp;&nbsp;&nbsp;<span className="str">"sleep1"</span>: {"{"} <span className="str">"val"</span>: <span className="kw">1000</span>, <span className="str">"description"</span>: <span className="str">"Sleep 1"</span> {"}"},</div>
    <div>&nbsp;&nbsp;&nbsp;&nbsp;<span className="str">"enableTest"</span>: {"{"} <span className="str">"val"</span>: <span className="kw">true</span>, <span className="str">"description"</span>: <span className="str">"Enable"</span> {"}"}</div>
    <div>&nbsp;&nbsp;{"}"},</div>
    <div>&nbsp;&nbsp;<span className="str">"keys"</span>: {"{"} <span className="str">"tab"</span>: <span className="str">"Tab"</span> {"}"}</div>
    <div>{"}"}</div>
  </>
);

const Contribute = ({ t }) => {
  const [tab, setTab] = useState2("script");
  return (
  <section className="section" id="contribute">
    <SectionHeader eyebrow={t.contribute.eyebrow} title={t.contribute.title} lead={t.contribute.lead} />
    <div className="reveal contribute-grid" style={{ marginTop: 32 }}>
      <div className="code-block">
        <div className="code-block-head">
          <div className="code-tabs">
            <button className={`code-tab ${tab === "script" ? "active" : ""}`} onClick={() => setTab("script")}>
              <Ico.Code size={12} /> my_macro.ahk
            </button>
            <button className={`code-tab ${tab === "config" ? "active" : ""}`} onClick={() => setTab("config")}>
              <Ico.Settings size={12} /> cfg/my_macro.json
            </button>
          </div>
        </div>
        <div className="code-block-body">
          {tab === "script" ? <ScriptExample /> : <ConfigExample />}
        </div>
      </div>
      <div>
        <ol className="contribute-list">
          {t.contribute.steps.map((s, i) => (
            <li key={i}><span className="num">{i + 1}</span><span>{s}</span></li>
          ))}
        </ol>
        <a href="https://github.com/Lazy-World/wf-macro" className="btn btn-outline btn-md" style={{ marginTop: 24 }}>
          <Ico.Github size={14} /> {t.contribute.ctaRepo} <Ico.ArrowRight size={14} />
        </a>
      </div>
    </div>
  </section>
  );
};

/* ===== Footer ===== */
const Footer = ({ t }) => (
  <footer className="footer">
    <div className="footer-inner">
      <div>
        <div className="footer-brand">
          <img src="assets/cat.svg" alt="" />
          <span>Cercony · ahk-manager</span>
        </div>
        <div className="footer-tagline">{t.footer.tagline}</div>
      </div>
      <div className="footer-links">
        <a href="https://github.com/Lazy-World/wf-macro-loader">{t.footer.links.repo}</a>
        <a href="https://github.com/Lazy-World/wf-macro">{t.footer.links.scripts}</a>
        <a href="https://github.com/Lazy-World/wf-macro-loader/releases">{t.footer.links.releases}</a>
        <a href="https://github.com/Lazy-World/wf-macro-loader/blob/main/LICENSE">{t.footer.links.license}</a>
      </div>
    </div>
    <div className="footer-stamp" style={{ maxWidth: 1120, margin: "0 auto" }}>
      <span>© Lazy-World · {new Date().getFullYear()}</span>
      <span>made with Geist · Lucide · React · &lt;3</span>
    </div>
  </footer>
);

window.What = What;
window.Features = Features;
window.Install = Install;
window.FAQ = FAQ;
window.Contribute = Contribute;
window.Footer = Footer;
