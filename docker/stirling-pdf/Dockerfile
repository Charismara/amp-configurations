# Custom AMP base image for the Stirling-PDF template.
#
# Extends the standard CubeCoders AMP base image with the native tools that
# Stirling-PDF shells out to for its "advanced" features:
#   * OCR            -> ocrmypdf + tesseract (+ ghostscript, qpdf, unpaper, pngquant)
#   * Office convert -> LibreOffice (soffice, headless)  [Word/Excel/PowerPoint/ODF <-> PDF]
#   * HTML/MD -> PDF -> weasyprint
#
# The tools are baked into the image so AMP instances start fast (no per-boot
# apt install). Java itself is still provided by the template's JRE download
# stage, so this image only needs the PDF/OCR/Office toolchain.
#
# This image is built and pushed automatically by
# .github/workflows/build-images.yml to
#   ghcr.io/charismara/stirling-pdf-ampbase   (tags: latest + <yyyy>-<mm>-<dd>.<build>)
#
# To build it manually instead (e.g. directly on the AMP host):
#   docker build -t ghcr.io/charismara/stirling-pdf-ampbase:latest docker/stirling-pdf/
#
# The template references it via:
#   Meta.SpecificDockerImage=ghcr.io/charismara/stirling-pdf-ampbase:latest
FROM cubecoders/ampbase:debian

ENV DEBIAN_FRONTEND=noninteractive \
    TESSDATA_PREFIX=/usr/share/tesseract-ocr/5/tessdata

# ampbase clears the apt lists, so refresh them before installing.
RUN apt-get update && apt-get install -y --no-install-recommends \
        # --- OCR stack (ocrmypdf pulls ghostscript, qpdf, unpaper, pngquant, jbig2dec, img2pdf, pikepdf) ---
        ocrmypdf \
        tesseract-ocr \
        tesseract-ocr-osd \
        tesseract-ocr-eng \
        tesseract-ocr-deu \
        tesseract-ocr-fra \
        tesseract-ocr-spa \
        tesseract-ocr-ita \
        # --- Office / document conversions via headless LibreOffice ---
        libreoffice-writer \
        libreoffice-calc \
        libreoffice-impress \
        libreoffice-draw \
        libreoffice-core \
        libreoffice-java-common \
        default-jre-headless \
        python3-uno \
        python3-venv \
        # --- HTML / Markdown -> PDF ---
        weasyprint \
        # --- General PDF tooling (explicit; some are also ocrmypdf deps) ---
        ghostscript \
        qpdf \
        poppler-utils \
        poppler-data \
        # --- Fonts for good conversion output ---
        fonts-dejavu \
        fonts-liberation2 \
        fonts-noto-core \
        fonts-noto-cjk \
        fontconfig \
    && rm -rf /var/lib/apt/lists/* \
    # Match the tool locations Stirling-PDF expects when it detects it is
    # running inside Docker (/opt/venv/bin/... and /usr/local/bin/...), so the
    # features work even without the explicit path overrides in the template.
    && mkdir -p /opt/venv/bin \
    && ln -sf /usr/bin/ocrmypdf   /opt/venv/bin/ocrmypdf \
    && ln -sf /usr/bin/weasyprint /opt/venv/bin/weasyprint \
    && fc-cache -f

# LibreOffice UNO server (unoserver) for Office <-> PDF conversions. Installed in
# its own venv with --system-site-packages so it can use the distro python3-uno.
# Pinned to 3.6 to match the unoconvert client version Stirling-PDF expects.
RUN python3 -m venv /opt/unoserver-venv --system-site-packages \
    && /opt/unoserver-venv/bin/pip install --no-cache-dir "unoserver==3.6" \
    && ln -sf /opt/unoserver-venv/bin/unoserver  /usr/local/bin/unoserver \
    && ln -sf /opt/unoserver-venv/bin/unoconvert /usr/local/bin/unoconvert \
    && ln -sf /opt/unoserver-venv/bin/unoping    /usr/local/bin/unoping

# Custom entrypoint: start unoserver in the background (for Office conversions),
# then hand off to AMP's /ampstart.sh which launches and manages the instance.
COPY entrypoint.sh /usr/local/bin/stirling-ampstart.sh
# Strip any CR (in case the repo was checked out with CRLF) so the shebang works.
RUN sed -i 's/\r$//' /usr/local/bin/stirling-ampstart.sh \
    && chmod 0755 /usr/local/bin/stirling-ampstart.sh
ENTRYPOINT ["/usr/local/bin/stirling-ampstart.sh"]
CMD []
