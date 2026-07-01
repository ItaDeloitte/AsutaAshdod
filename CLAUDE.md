# AssutaMerkazim — מצב פרויקט פריסה

## סביבות

| שם | Alias | Username | תפקיד |
|---|---|---|---|
| סנדבוקס | `AsutaDev` | rpincus@deloitte.co.il.ashdod.prod.dev2 | יעד ראשון |
| פרודקשין | `AsutaProd` | rpincus@deloitte.co.il.ashdod.prod | יעד שני |

**תיקיית פרויקט:** `c:\Users\rpincus\Documents\ASUTA MERKAZIM\הקבצים של Shmaryahu, Aviel - AssutaMerkazim`

---

## תיעוד

| קובץ | תוכן |
|---|---|
| `DEPLOYMENT_LOG_SANDBOX.md` | יומן פריסה — Sandbox |
| `DEPLOYMENT_LOG.md` | יומן פריסה — Production |
| `MANUAL_CHANGES.md` | שגיאות גל 2 + תיקונים שבוצעו |
| `package_wave_1.xml` | רכיבי גל 1 שהצליחו |
| `package_wave_2.xml` | יוצר לאחר הצלחת גל 2 |
| Excel: `C:\Users\rpincus\Deloitte (O365D)\אסותא אשדוד - אסותא אשדוד\העתקת סביבה\תהליך פריסה\סטטוס פריסת רכיבים.xlsx` | תיעוד מלא — 5 גיליונות |

---

## סטטוס גלים — Sandbox

| גל | מטאדאטה | סטטוס | הערות |
|---|---|---|---|
| 1א | CustomLabels | ✅ | 699 רכיבים |
| 1ב | StandardValueSet | ➖ | אין רכיבים |
| 1ג | GlobalValueSet | ✅ | 33 רכיבים |
| 1ד | CustomPermission | ✅ | 3 רכיבים |
| 1ה | StaticResource | ✅ | 53 רכיבים |
| 1ו | ContentAsset | ➖ | אין רכיבים |
| 1ז | Letterhead | ✅ | 1 רכיב |
| 1ח–1ט | EmailFolder, ReportFolder | ➖ | אין רכיבים |
| **2** | **CustomObject** | **🔄 ריצה 5** | ריצה 1: 8,942/1,293 ❌ \| ריצה 2: 9,180/805 ❌ \| ריצה 3: 9,564/836 ❌ \| ריצה 4: 9,485/741 ⚠️ \| ריצה 5: בתהליך |
| 3 | CustomMetadata, Translations | ⬜ | |
| 4 | Role, Group, Queue | ⬜ | |
| 5 | ApexClass, ApexTrigger | ⬜ | |
| 6 | LWC, Aura, VF, ApexPage | ⬜ | |
| 7 | MatchingRules, Workflow, Approval | ⬜ | |
| 8 | Flow, FlowDefinition | ⬜ | FlowDefinition חייב אחרי Flow |
| 9 | DataIntegrationRule, SharingRules, PathAssistant | ⬜ | |
| 10 | Layout, FlexiPage, QuickAction, App | ⬜ | |
| 11 | Report, Dashboard | ⬜ | |
| 12 | PermissionSet, PermissionSetGroup | ⬜ | PermissionSetGroup אחרי PermissionSet |
| 13 | Profile | ⬜ | ידנית |

---

## פקודות פריסה

```bash
# גל 2 — Objects
sf project deploy start --source-dir "force-app/main/default/objects" --target-org AsutaDev --test-level NoTestRun --json

# גל 3 — Translations
sf project deploy start --metadata "CustomMetadata,CustomObjectTranslation,GlobalValueSetTranslation,StandardValueSetTranslation,Translations" --target-org AsutaDev --test-level NoTestRun

# גל 4 — Roles & Queues
sf project deploy start --metadata "Role,Group,Queue" --target-org AsutaDev --test-level NoTestRun

# גל 5 — Apex
sf project deploy start --metadata "ApexClass,ApexTrigger" --target-org AsutaDev --test-level RunLocalTests

# גל 6 — UI Components
sf project deploy start --metadata "LightningMessageChannel,ExternalServiceRegistration,AuraDefinitionBundle,LightningComponentBundle,ApexComponent,ApexPage" --target-org AsutaDev --test-level NoTestRun

# גל 7 — Automation
sf project deploy start --metadata "ApplicationSubtypeDefinition,MatchingRules,DuplicateRule,AssignmentRules,ApprovalProcess,Workflow" --target-org AsutaDev --test-level NoTestRun

# גל 8 — Flows
sf project deploy start --metadata "Flow" --target-org AsutaDev --test-level NoTestRun
sf project deploy start --metadata "FlowDefinition" --target-org AsutaDev --test-level NoTestRun

# גל 9 — Rules
sf project deploy start --metadata "DataIntegrationRule,SharingRules,PathAssistant" --target-org AsutaDev --test-level NoTestRun

# גל 10 — UI Config
sf project deploy start --metadata "ReportType,QuickAction,CustomTab,CustomApplication,Layout,FlexiPage" --target-org AsutaDev --test-level NoTestRun

# גל 11 — Reports
sf project deploy start --source-dir "force-app/main/default/reports" --target-org AsutaDev --test-level NoTestRun
sf project deploy start --source-dir "force-app/main/default/dashboards" --target-org AsutaDev --test-level NoTestRun

# גל 12 — Permissions
sf project deploy start --metadata "PermissionSet" --target-org AsutaDev --test-level NoTestRun
sf project deploy start --metadata "PermissionSetGroup" --target-org AsutaDev --test-level NoTestRun

# פרודקשין — אותן פקודות עם --target-org AsutaProd --test-level RunLocalTests
```

---

## תיקוני קוד שבוצעו (אל תבטל!)

### 1. `.forceignore` — רכיבים מוחרגים מכל פריסה
**Managed Packages** (מותקנים כחבילות, לא ניתנים לפריסה מ-source):
- `HealthCloudGA` — Health Cloud (דורש רישיון Salesforce)
- `et4ae5` — Marketing Cloud Connector
- `Form_Builder` — FormTitan
- `kmslh` — KMS Lighthouse (מאומת שמותקן בסנדבוקס)
- `OB_Archiver`, `CodeBuilder`, `esp2p`

**Salesforce Connect** (OData 4.0 — דורש רישיון נפרד):
- `AssutaDBHistoric` — External Data Source
- `dbo_CONV_SF_Activity_Fields_c__x` — External Object

**אובייקטים סטנדרטיים לא מופעלים** (~91 סה"כ — ראה MANUAL_CHANGES.md לרשימה מלאה):
- AI/Agentforce (34): AiGrounding, DataKnowledge, MktMLModel, DataGraph, ועוד
- Revenue Cloud (16): CreditMemo, Invoice, Payment, PaymentGateway, ועוד
- Survey (7): SurveyInvitation, SurveyPage, SurveyResponse, ועוד
- Experience Cloud (6): NetworkMember, SharingRecordCollection, ועוד
- Video/Voice (4): VideoCall, VoiceCall, ועוד
- Service Cloud Advanced (5): AgentWorkSkill, ContextAgent, ועוד
- אחר (10): AccountBrand, IdentityResolution, ועוד

### 2. תגי Gender — הוסרו מ-62 קבצי XML
עברית = gender neutral ב-Salesforce. תגי `<gender>` גורמים לשגיאה.
- 30 קבצים סיבוב 1 + 32 קבצים סיבוב 2 = 62 סה"כ
- objects/ ו-objectTranslations/

### 3. Field History Tracking — הוסר מכל השדות (✅ תוקן ריצה 4, 30/06/2026)
מגבלת Salesforce: 20 שדות עם `trackHistory=true` לאובייקט.

**⚠️ שגיאת נתיב:** ריצות 1-3 תיקנו בנתיב שגוי (`objects/`) — לא הועיל. ריצה 4 תיקנה בנתיב הנכון.

**תיקון סופי — 131 שדות ב-`force-app/main/default/objects/`:**
- `Appointment__c`: 38 שדות → 0 (כולם false)
- `Case`: 29 שדות → 0 (כולם false)
- `Doctor_in_Clinic__c`: 21 שדות → 0 (כולם false)
- `File__c`: 23 שדות → 0 (כולם false)
- `QualityControl__c`: 20 שדות → 0 (כולם false)
- `Account`: 8 שדות — ✅ בגבולות (לא שונה)

**לשחזור לאחר פריסה:** המיישמת תפעיל ידנית עד 20 שדות לאובייקט.
- תיעוד מלא: גיליון Excel **"Field History — שינויים"**

### 3ב. .forceignore — הוספות ריצה 4
בנוסף ל-~91 שהיו, נוספו:
- **Health Cloud objects (9):** CareProviderSearchableField, AgeBandHlthRskAdjFctr, וכו'
- **Standard objects (3):** AccountContactRelation, DigitalWallet, Survey (הסטנדרטי)
- **Standard fields (26):** IsCustomerPortal, IsPartner, CaseMilestone.StoppedTime*, EntityMilestone.*, IsVisibleInSelfService, PortalRole, PartnerAccountId, FolderId
- **Case Lookup fields (7):** 7 שדות יחס ב-Case שחורגים ממגבלת 40 — ⚠️ לשחזור ידני!
- **SurveyTaker__c rollup fields (4):** שדות סיכום שמפנים ל-SurveyQuestionResponse__c
- **Form_Builder refs (2):** My_Submission__c ב-ConsentFormTaken__c + SurveyTaker__c

### 3ג. .forceignore — הוספות ריצה 5 (30/06/2026)
- **Appointment__c Time formula fields (2):** `Appointment_Time__c`, `Time_of_appointment__c` — שדות Time עם FORMULA_PENDING ⚠️ לשחזור
- **Dependent picklists (3):** `Opportunity.StageStatus__c`, `Case.tofes_web__c`, `Case.subStatus__c` — ערכי שליטה חסרים בסנדבוקס ⚠️ לשחזור
- **Case Validation Rule (1):** `Case/validationRules/DEL_Stop_case_360_if_not_moked` — מפנה לשדה rec_to_modify_case__c שהוחרג ⚠️ לשחזור

### 4. Appointment__c List Views — תיקון Boolean Filters (ריצה 5)
3 list views הכילו booleanFilter שהפנה למסנן PaymentsRead__c שלא נפרס:
- **FIFO1:** הוסר מסנן PaymentsRead__c (#8), booleanFilter → `1 AND 2 AND 3 AND 4 AND 5 AND (6 OR 7)` ⚠️ לשחזור
- **FIFO2:** הוסר מסנן PaymentsRead__c (#9), booleanFilter → `1 AND 2 AND 3 AND 4 AND 5 AND 6 AND (7 OR 8)` ⚠️ לשחזור
- **MACCABINEWLAYOUT:** הוסר מסנן PaymentsRead__c (#7 מתוך `6 AND 7`), מסננים מוספרו מחדש, booleanFilter → `1 AND 2 AND 7 AND 8 AND (3 OR 4 OR 5 OR 6) AND 9` ⚠️ לשחזור

### 5. Case Filtered Lookups — הושבתו (ריצה 5)
מגבלה: 5 active filtered lookups לאובייקט. Case היה עם 11.
**11 שדות הוגדרו `active=false`:** Agreement__c, Appointment_Details__c, Doctor_case__c, HMODoctor__c, Opearator__c, Opened_by_Doctor__c, Patient__c, Recommended_doc__c, Site_Public_Inquiry__c, Site__c, Surgery_Name__c
**⚠️ לשחזור ידני:** להחזיר active=true בכל 11 השדות לאחר פריסה מלאה (דרך metadata, לא UI).

### 6. תיקוני Picklist (ריצה 5)
- **Case.preferd_chanal_case__c:** הוסר ערך כפול inactive `fullName=דואר אלקטרוני`
- **Medical_Procedure__c.Status__c:** הוסרו 4 ערכים inactive כפולים (fullName=ל, fullName=לא פעיל, fullName=פ, fullName=פעיל)
- **Case.Treat_status__c:** הוסר ערך עם fullName ריק — פתר cascade של 20+ שגיאות list view

### 7. תיקוני List Views (ריצה 5)
- **ServiceAppointment (3 LV):** הוסרה עמודת WorkTypeName (FSL לא מופעל) — All_ServiceAppointments, MyPendingAppointments, MyScheduledAppointments ⚠️ לשחזור
- **Case.X360:** הוסרה עמודת rec_to_modify_case__c (שדה ב-.forceignore) ⚠️ לשחזור
- **Medical_Procedure__c.search_by_search_name:** ערך פילטר שונה מ-`1,פעיל` ל-`1`

### 8. תיקוני שונים (ריצה 5)
- **Survey__c:** הוסרו actionOverrides (Edit+New) שהפנו ל-GSurveys VF page ⚠️ לשחזור אם GSurveys נפרסת
- **QualityControl__c.Consequences__c:** הוסף ערך `בקרה פנימית` (היה חסר, RecordTypes closeqa+open_qa הפנו אליו)

### 10. Formulas — Cross-Object Reference Limit
מגבלת Salesforce: מקסימום **15 שדות formula עם cross-object reference לאובייקט**.

**174 שדות עודכנו** — הנוסחה המקורית נשמרה ב-`<description>`, הוחלפה ב-placeholder:

| אובייקט | שדות שעודכנו |
|---|---|
| `Appointment__c` | 78 שדות |
| `Case` | 35 שדות |
| `Guidance_Scenario__c` | 60 שדות |
| `Reminder__c` | 1 שדה (Site_Code__c) |

#### איך לשחזר נוסחה:
1. פתח את קובץ השדה: `force-app/main/default/objects/[Object]/fields/[Field].field-meta.xml`
2. העתק את הערך מ-`<description>FORMULA_PENDING | Original: [כאן הנוסחה]</description>`
3. הדבק לתוך `<formula>...</formula>`
4. מחק את הטקסט `FORMULA_PENDING | Original: ...` מה-`<description>`
- תיעוד מלא: גיליון Excel **"Formulas — נוסחאות בהמתנה"**

---

## ממתין למיישמת / לשחזור לאחר פריסה

| משימה | סטטוס | פרטים |
|---|---|---|
| הפעלת Person Accounts | ✅ הופעל | |
| התקנת Managed Packages | ⏸️ תקוע | HealthCloudGA, et4ae5, Form_Builder, kmslh, OB_Archiver |
| תיקון ערכי Picklist חסרים | ⏳ ממתין לגל 2 | ~25 שגיאות: "בטיפול", "הועבר לטיפול מזכירות" וכו' |
| הפעלת Salesforce Connect (OData 4.0) | ⏸️ תקוע | דורש רישיון נפרד |
| שחזור Field History | ⬜ לאחר פריסה מלאה | 131 שדות הופסקו — עד 20 לאובייקט |
| שחזור 7 Case Lookup fields | ⬜ לאחר פריסה | doc_arrangment_not_private_hidden__c, memograph_exam__c, rec_to_modify_case__c, reco_after_memo__c, related_Case_rec__c, surgeon_doctor__c, surgeryMatchedArrangement__c |
| שחזור נוסחאות (174 שדות) | ⬜ לאחר סטבילזציה | הנוסחה בתוך ה-`<description>` |
| שחזור Form_Builder fields | ⬜ אחרי התקנת Form_Builder | My_Submission__c ב-ConsentFormTaken__c + SurveyTaker__c |
| שחזור SurveyTaker__c rollup fields | ⬜ אחרי הפעלת Survey | 4 שדות |
| שחזור 11 Case Filtered Lookups | ⬜ לאחר פריסה מלאה | להחזיר active=true לכל 11 השדות |
| שחזור FIFO1/FIFO2/MACCABI — PaymentsRead__c filter | ⬜ לאחר פריסת PaymentsRead__c | להחזיר מסנן ל-3 list views ולעדכן booleanFilter |
| שחזור ServiceAppointment WorkTypeName | ⬜ אחרי הפעלת FSL | 3 list views: All, MyPending, MyScheduled |
| שחזור Case.X360 — rec_to_modify_case__c column | ⬜ לאחר פריסת rec_to_modify_case__c | |
| שחזור Case.DEL_Stop validation rule | ⬜ לאחר פריסת rec_to_modify_case__c | להסיר מ-.forceignore ולפרוס |
| שחזור Appointment__c Time formula fields | ⬜ לאחר כתיבת נוסחה נכונה | Appointment_Time__c + Time_of_appointment__c |
| שחזור Opportunity.StageStatus__c | ⬜ לאחר הוספת Stage custom values | להסיר מ-.forceignore ולפרוס |
| שחזור Case.tofes_web__c | ⬜ לאחר הוספת Origin values | להסיר מ-.forceignore ולפרוס |
| שחזור Case.subStatus__c | ⬜ לאחר הוספת Status Hebrew values | להסיר מ-.forceignore ולפרוס |
| שחזור Survey__c GSurveys overrides | ⬜ אחרי פריסת GSurveys VF page (גל 6) | 2 actionOverrides: Edit + New |
| שחזור HealthCloudGA GVS refs ב-RecordTypes | ⬜ אחרי התקנת HealthCloudGA | הוסרו blocks של GVS בריצות קודמות |
| הפעלת Lead History + שחזור 131 Field History | ⬜ לאחר פריסה | |

---

## לפני פריסה לפרודקשין

1. גל 2 חייב להצליח בסנדבוקס
2. כל הגלים 3–12 חייבים לעבור בסנדבוקס
3. לשנות `--target-org AsutaDev` ← `AsutaProd`
4. לשנות `--test-level NoTestRun` ← `--test-level RunLocalTests`
5. לוודא שהמיישמת ביצעה את כל משימות ה-Setup גם בפרודקשין
6. לשחזר נוסחאות (174 שדות) — רק אחרי שהסביבה יציבה

---

## Excel — גיליונות

| גיליון | תוכן |
|---|---|
| סטטוס פריסה | סטטוס גלים 1–13 עם כמויות |
| שגיאות גל 2 — Sandbox | 10 קטגוריות שגיאה + סטטוס ביצוע |
| Field History — שינויים | 31 שדות שצומצמו |
| Formulas — נוסחאות בהמתנה | 174 שדות עם נוסחאות שמורות |
| משימות לפני פריסה | חלק א (מיישם) + חלק ב (מפתח) |
