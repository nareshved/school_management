# Design System Specification: The Scholastic Curator

## 1. Overview & Creative North Star
This design system moves away from the "industrial utility" typical of educational software and moves toward **The Scholastic Curator**. Our goal is to balance the authoritative weight of a prestigious institution with the fluid, effortless navigation of a high-end editorial app.

We reject the "boxed-in" look of standard Material 3 implementations. Instead of rigid containers and heavy dividers, we utilize **intentional asymmetry, overlapping tonal layers, and sophisticated typographic hierarchy**. The experience should feel like a bespoke digital journal—clean, expansive, and intellectually empowering.

## 2. Colors: Tonal Depth & The "No-Line" Rule
Our palette is anchored in **Deep Indigo (#1A237E)** for authority and **Teal (#00897B)** for focused action. However, the premium feel is achieved through how these colors interact with our surfaces.

### The "No-Line" Rule
**Explicit Instruction:** You are prohibited from using 1px solid borders to define sections, cards, or inputs. 
Boundaries must be defined through:
*   **Tonal Shifts:** Placing a `surface-container-low` (#f3f3f3) element on a `surface` (#f9f9f9) background.
*   **Vertical Space:** Utilizing the `24dp` (token `8.5rem`) section spacing to allow the eye to categorize content groups.

### Surface Hierarchy & Nesting
Think of the UI as a series of physical layers of fine paper. 
*   **Base:** `surface` (#f9f9f9).
*   **Secondary Content:** `surface-container-low` (#f3f3f3) for grouping related items.
*   **Elevated Focus:** `surface-container-lowest` (#ffffff) for primary cards and interaction points.
*   **Deep Interaction:** `primary-container` (#1a237e) used as a background for high-impact stats or hero sections, paired with `on-primary-container` (#8690ee) for text.

### The Glass & Gradient Rule
To prevent the app from feeling "flat," use subtle linear gradients for main CTAs (Primary to Primary-Container). For floating elements (like a Bottom Navigation Bar or a Filter FAB), apply **Glassmorphism**: use `surface` at 85% opacity with a 16px backdrop blur to allow content to bleed through softly.

## 3. Typography: Editorial Authority
We utilize two typefaces to create a "Curated" feel: **Manrope** for structural impact and **Inter** for legible utility.

*   **Display Large/Medium (Manrope):** Use these for "Moment" screens (e.g., "Good Morning, Professor"). Use tight letter-spacing (-2%) to create a modern, high-end feel.
*   **Headline Small (Manrope):** The standard for screen titles. Bold and authoritative.
*   **Body Medium (Inter):** Our workhorse. Ensure a line-height of at least 1.5 to maintain "breathing room" in dense student data lists.
*   **Label Small (Inter):** Used sparingly for "Metadata" (e.g., timestamps, student IDs). Use `on_surface_variant` (#454652) to keep these secondary.

## 4. Elevation & Depth: The Layering Principle
We do not use standard "Drop Shadows." We use **Ambient Shadows and Tonal Stacking.**

### Ambient Shadows
When an element must float (Level 2 or 3), use an extra-diffused shadow:
*   **Color:** Tint the shadow with `primary` (#000666) at 6% opacity.
*   **Blur:** 24px–32px.
*   **Offset:** (0, 8).
This mimics natural light rather than a digital "glow."

### The "Ghost Border" Fallback
If an element lacks contrast against a surface, you may use a "Ghost Border": `outline-variant` (#c6c5d4) at **15% opacity**. It should be felt, not seen.

## 5. Components: Refined Primitives

### Cards & Lists
*   **No Dividers:** Never use a horizontal line to separate students in a list. Use `spacing.2` (0.7rem) of vertical white space or alternating tonal backgrounds (`surface` to `surface-container-low`).
*   **Shape:** Use **Large (16dp)** for standard cards and **Extra Large (28dp)** for hero containers to create a soft, approachable aesthetic.

### Buttons (CTAs)
*   **Primary:** A subtle gradient from `primary` to `primary_container`. Shape: **Full (9999px)**.
*   **Secondary:** No fill. Use a Ghost Border and `secondary` (#006b5f) text.
*   **Tertiary (Amber):** Reserved strictly for "Warning" or "Urgent Action" (e.g., Overdue Fees, Missing Attendance).

### Input Fields
*   **Style:** Filled, but with a background of `surface-container-high`. 
*   **Indicator:** Instead of a full-box border, use a 2dp bottom indicator in `primary` that expands only on focus.
*   **Shape:** **Small (8dp)** top corners only.

### Chips (Filtering)
*   Use `secondary_container` (#8df5e4) for active states.
*   Shape: **Medium (12dp)**. These should look like soft lozenges, never sharp rectangles.

### Interactive "Smart" Components
*   **Progress Rings:** Use `secondary` (#00897b) with a `secondary_container` track for grade averages.
*   **Status Indicators:** Use `tertiary` (Amber) for "Pending" and `error` (#D32F2F) for "Absent," but always in small, circular "Dot" formats to maintain the clean editorial look.

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical layouts for dashboards—e.g., a large "Today's Schedule" card next to a smaller "Quick Actions" stack.
*   **Do** prioritize white space. If a screen feels "full," increase the `spacing.6` (2rem) between sections.
*   **Do** use Material Symbols Rounded (Filled) only for the active state in the Bottom Nav to signify focus.

### Don't
*   **Don't** use 100% black text. Use `on_surface` (#1a1c1c) to keep the contrast accessible but "soft."
*   **Don't** use standard Material 3 "Tonal Buttons" (which often look like grey blobs). Stick to our gradient Primary or Ghost Secondary.
*   **Don't** use sharp corners. Every interaction point must have at least an 8dp (Small) radius to maintain the "Education-focused" friendliness.
*   **Don't** use high-contrast dividers. A change in background color is always superior to a line.

---
**Director's Final Note:** This system is about the *space between* elements as much as the elements themselves. Respect the 8dp grid, but let the typography breathe. We are building a tool for educators; it should feel as organized and inspiring as a well-kept library.