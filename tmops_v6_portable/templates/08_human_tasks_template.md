<!--
📁 FILE: /home/anthonycalek/projects/tmops_framework/CODE/tmops-header-standardization/tmops_v6_portable/templates/08_human_tasks_template.md
🎯 PURPOSE: Template for identifying and tracking human-only tasks requiring authentication, payments, or manual configuration
🤖 AI-HINT: Use to systematically identify tasks that AI agents cannot complete and require human intervention
🔗 DEPENDENCIES: Project planning, deployment workflows, third-party integrations
📝 CONTEXT: Part of template library for agentic development workflows where AI does 95%+ of coding
-->

---

# Human Tasks Template - Manual Actions & Authentication Requirements

# Version: 1.0.0

# License: CC BY 4.0

# Purpose: Identify and document tasks requiring human intervention (auth, payments, manual config)

meta:
version: "1.0.0"
template_name: "human_tasks_checklist"
id: "HUMAN-XXXX"
title: "Human Tasks: [Project/Feature Name]"
type: "checklist"
date: "YYYY-MM-DD"
project: "[Project Name]"
author: "@handle"
status: "pending|in_progress|blocked|complete"
priority: "immediate|scheduled|deferred"

task_context:
deployment_stage: "development|staging|production"
platforms: ["vercel", "supabase", "gcp", "aws", "other"]
blocking_development: true|false
estimated_duration: "XX minutes|hours"

---

# Human Tasks Checklist: [Project/Feature Name]

## AI Instructions

> **For AI Agents:** You are identifying tasks that CANNOT be automated and REQUIRE human intervention.
>
> 1. **Scan Project Requirements**: Identify authentication needs, payment setups, manual configurations
> 2. **Check Platform Dependencies**: List services requiring account creation or API keys
> 3. **Security & Compliance**: Flag items needing human verification or approval
> 4. **Be Comprehensive**: Include obvious and non-obvious human-only tasks
> 5. **Provide Context**: Explain WHY each task requires human action
> 6. **Include Prerequisites**: List what's needed before each task
> 7. **Add Time Estimates**: Help humans plan their involvement
> 8. **Link Resources**: Provide URLs to relevant documentation/dashboards

## Executive Summary

### Critical Blockers

<!-- Tasks that completely block development if not completed -->

| Task | Platform | Blocks | Time Est | Status |
|------|----------|--------|----------|--------|
| API Key Generation | Supabase | Database access | 5 min | ⏳ Pending |
| Domain Verification | Vercel | Production deploy | 15 min | ⏳ Pending |
| Payment Method | OpenAI | API usage | 10 min | ⏳ Pending |

### Non-Blocking Tasks

<!-- Tasks that can be deferred but will be needed eventually -->

| Task | Platform | Needed By | Time Est | Status |
|------|----------|-----------|----------|--------|
| Analytics Setup | Google | Launch | 30 min | 📋 Scheduled |
| SSL Certificate | Cloudflare | Production | 20 min | 📋 Scheduled |

## Platform Setup Tasks

### Cloud Infrastructure

#### ☐ Vercel

**Why Human Required**: Account creation, billing setup, domain configuration
**Prerequisites**: Email address, payment method
**Time Estimate**: 15-30 minutes

- [ ] Create Vercel account at https://vercel.com/signup
- [ ] Add payment method (Settings → Billing)
- [ ] Create new project
- [ ] Link GitHub repository
- [ ] Set environment variables:
  ```
  NEXT_PUBLIC_SUPABASE_URL
  NEXT_PUBLIC_SUPABASE_ANON_KEY
  DATABASE_URL
  ```
- [ ] Configure custom domain (if applicable)
- [ ] Set deployment protection (optional)

**Resources**: 
- Dashboard: https://vercel.com/dashboard
- Docs: https://vercel.com/docs

#### ☐ Supabase

**Why Human Required**: Database credentials, Row Level Security policies
**Prerequisites**: Email, GitHub/Google account
**Time Estimate**: 20-30 minutes

- [ ] Create account at https://supabase.com
- [ ] Create new project (choose region)
- [ ] Note down credentials:
  ```
  Project URL: _______________
  Anon Key: __________________
  Service Role Key: ___________
  Database Password: __________
  ```
- [ ] Configure Auth providers (if needed):
  - [ ] Email/Password
  - [ ] OAuth (Google, GitHub, etc.)
  - [ ] Magic Links
- [ ] Set up Row Level Security policies
- [ ] Configure database backups

**Resources**:
- Dashboard: https://app.supabase.com
- Docs: https://supabase.com/docs

#### ☐ Google Cloud Platform

**Why Human Required**: Project creation, billing, service account generation
**Prerequisites**: Google account, payment method
**Time Estimate**: 30-45 minutes

- [ ] Create GCP account at https://console.cloud.google.com
- [ ] Create new project
- [ ] Enable billing (required for most services)
- [ ] Enable required APIs:
  - [ ] Cloud Run API
  - [ ] Cloud Build API
  - [ ] Container Registry API
  - [ ] Cloud Logging API
- [ ] Create service account
- [ ] Download service account key JSON
- [ ] Set up Cloud Run service (if applicable)
- [ ] Configure custom domain mapping

**Resources**:
- Console: https://console.cloud.google.com
- Cloud Run: https://console.cloud.google.com/run

#### ☐ AWS

**Why Human Required**: Account verification, MFA setup, IAM configuration
**Prerequisites**: Email, phone, payment method
**Time Estimate**: 45-60 minutes

- [ ] Create AWS account
- [ ] Complete phone verification
- [ ] Set up MFA on root account
- [ ] Create IAM user for programmatic access
- [ ] Generate access keys:
  ```
  AWS_ACCESS_KEY_ID: __________
  AWS_SECRET_ACCESS_KEY: _______
  ```
- [ ] Configure S3 bucket (if needed)
- [ ] Set up RDS/DynamoDB (if needed)
- [ ] Configure CloudFront CDN

**Resources**:
- Console: https://aws.amazon.com/console/
- IAM: https://console.aws.amazon.com/iam/

## API Keys & Authentication

### Third-Party Services

#### ☐ OpenAI / Anthropic

**Why Human Required**: API key generation, usage limits, billing
**Prerequisites**: Account, payment method
**Time Estimate**: 10 minutes

- [ ] Create account at https://platform.openai.com
- [ ] Add payment method
- [ ] Generate API key
- [ ] Set usage limits (recommended)
- [ ] Note organization ID (if applicable)

#### ☐ Stripe / Payment Processing

**Why Human Required**: KYC verification, bank account linking
**Prerequisites**: Business entity, bank account, tax ID
**Time Estimate**: 1-3 days (verification)

- [ ] Create Stripe account
- [ ] Complete identity verification
- [ ] Add bank account
- [ ] Generate API keys:
  ```
  Publishable Key: pk_test_...
  Secret Key: sk_test_...
  Webhook Secret: whsec_...
  ```
- [ ] Configure webhook endpoints
- [ ] Set up products/prices (if applicable)

#### ☐ Email Service (SendGrid/Postmark)

**Why Human Required**: Domain verification, sender authentication
**Prerequisites**: Domain access, DNS control
**Time Estimate**: 30 minutes

- [ ] Create account
- [ ] Verify email domain
- [ ] Set up DNS records:
  - [ ] SPF record
  - [ ] DKIM records
  - [ ] DMARC policy
- [ ] Generate API key
- [ ] Configure sender identity
- [ ] Set up templates (optional)

## Domain & DNS Configuration

#### ☐ Domain Registration

**Why Human Required**: Purchase, ownership verification
**Prerequisites**: Payment method
**Time Estimate**: 15 minutes

- [ ] Purchase domain from registrar
- [ ] Configure nameservers
- [ ] Set up DNS records:
  ```
  A Record: @ → IP
  CNAME: www → domain.com
  MX Records: (for email)
  TXT Records: (for verification)
  ```
- [ ] Enable DNSSEC (recommended)
- [ ] Configure domain privacy

#### ☐ SSL Certificates

**Why Human Required**: Domain validation, certificate installation
**Prerequisites**: Domain control
**Time Estimate**: 20 minutes

- [ ] Generate CSR (if required)
- [ ] Complete domain validation
- [ ] Download certificate files
- [ ] Install on server/CDN
- [ ] Configure auto-renewal

## Security & Compliance

### Credentials & Secrets

#### ☐ Environment Variables

**Why Human Required**: Secure storage, access control
**Prerequisites**: Platform access
**Time Estimate**: 15 minutes

- [ ] Development (.env.local):
  ```
  DATABASE_URL=
  NEXT_PUBLIC_SUPABASE_URL=
  NEXT_PUBLIC_SUPABASE_ANON_KEY=
  INTERNAL_API_SECRET=
  ```
- [ ] Staging environment
- [ ] Production environment
- [ ] CI/CD secrets (GitHub Actions)

#### ☐ OAuth Application Setup

**Why Human Required**: App registration, redirect URI configuration
**Prerequisites**: Developer accounts
**Time Estimate**: 20 minutes per provider

- [ ] Google OAuth:
  - [ ] Create OAuth 2.0 credentials
  - [ ] Add authorized redirect URIs
  - [ ] Configure consent screen
- [ ] GitHub OAuth:
  - [ ] Register OAuth App
  - [ ] Set authorization callback URL
- [ ] Facebook/Meta:
  - [ ] Create app
  - [ ] Add platform (web)
  - [ ] Configure OAuth redirect

### Compliance Requirements

#### ☐ Legal Documents

**Why Human Required**: Legal review, signature authority
**Prerequisites**: Legal counsel
**Time Estimate**: Varies

- [ ] Terms of Service
- [ ] Privacy Policy
- [ ] Cookie Policy
- [ ] GDPR compliance
- [ ] Data Processing Agreements

#### ☐ Security Audits

**Why Human Required**: Manual review, penetration testing
**Prerequisites**: Security tools/consultant
**Time Estimate**: 1-5 days

- [ ] Vulnerability scanning
- [ ] Penetration testing
- [ ] Code security review
- [ ] Dependency audit
- [ ] Access control review

## Monitoring & Analytics

#### ☐ Error Tracking (Sentry)

**Why Human Required**: Project creation, DSN configuration
**Prerequisites**: Account
**Time Estimate**: 15 minutes

- [ ] Create Sentry account
- [ ] Create project
- [ ] Note DSN:
  ```
  SENTRY_DSN=https://...@sentry.io/...
  ```
- [ ] Configure source maps
- [ ] Set up alerts

#### ☐ Analytics (Google Analytics / Plausible)

**Why Human Required**: Property creation, tracking code
**Prerequisites**: Account
**Time Estimate**: 20 minutes

- [ ] Create property/site
- [ ] Get tracking ID/code
- [ ] Configure goals/events
- [ ] Set up custom dimensions
- [ ] Link to Search Console

## App Store & Marketplace

#### ☐ Apple App Store

**Why Human Required**: Developer account, app review
**Prerequisites**: Apple ID, $99/year fee, Mac
**Time Estimate**: 1-2 weeks (review)

- [ ] Enroll in Apple Developer Program
- [ ] Create App ID
- [ ] Generate certificates
- [ ] Create provisioning profiles
- [ ] Submit for review

#### ☐ Google Play Store

**Why Human Required**: Developer account, app review
**Prerequisites**: Google account, $25 one-time fee
**Time Estimate**: 2-3 days (review)

- [ ] Create developer account
- [ ] Set up merchant account
- [ ] Create app listing
- [ ] Upload APK/AAB
- [ ] Submit for review

## Banking & Financial

#### ☐ Business Banking

**Why Human Required**: Identity verification, signatures
**Prerequisites**: Business entity, EIN/Tax ID
**Time Estimate**: 1-2 weeks

- [ ] Open business account
- [ ] Set up ACH/wire capabilities
- [ ] Configure API access (if available)
- [ ] Set up recurring payments
- [ ] Add authorized users

#### ☐ Accounting Integration

**Why Human Required**: Account linking, authorization
**Prerequisites**: Accounting software account
**Time Estimate**: 30 minutes

- [ ] Connect to QuickBooks/Xero
- [ ] Map chart of accounts
- [ ] Configure sync rules
- [ ] Set up invoice automation
- [ ] Enable expense tracking

## Testing & Verification

### Manual Verification Steps

#### ☐ User Acceptance Testing

**Why Human Required**: Subjective evaluation, stakeholder signoff
**Prerequisites**: Staging environment
**Time Estimate**: 2-4 hours

- [ ] Test critical user flows
- [ ] Verify UI/UX meets requirements
- [ ] Check responsive design
- [ ] Test accessibility features
- [ ] Stakeholder review & signoff

#### ☐ Production Smoke Tests

**Why Human Required**: Real environment validation
**Prerequisites**: Production deployment
**Time Estimate**: 30 minutes

- [ ] Verify all services running
- [ ] Test authentication flow
- [ ] Verify payment processing
- [ ] Check email delivery
- [ ] Monitor error rates

## Communication Channels

#### ☐ Team Communication

**Why Human Required**: Account invites, permissions
**Prerequisites**: Platform accounts
**Time Estimate**: 15 minutes

- [ ] Slack workspace setup
- [ ] Discord server creation
- [ ] Microsoft Teams configuration
- [ ] Add team members
- [ ] Configure integrations

#### ☐ Customer Support

**Why Human Required**: Tool configuration, training
**Prerequisites**: Support platform account
**Time Estimate**: 1-2 hours

- [ ] Set up help desk (Zendesk/Intercom)
- [ ] Configure auto-responders
- [ ] Create knowledge base
- [ ] Set up chat widget
- [ ] Train support team

## Deployment Checklist

### Pre-Deployment

- [ ] All API keys configured
- [ ] Database migrations tested
- [ ] SSL certificates active
- [ ] DNS propagated
- [ ] Monitoring configured
- [ ] Backups scheduled

### Post-Deployment

- [ ] Verify all services operational
- [ ] Check performance metrics
- [ ] Monitor error rates
- [ ] Test critical paths
- [ ] Update status page

## Action Priority Matrix

### Immediate (Blocking Development)

1. [ ] Platform account creation
2. [ ] API key generation
3. [ ] Database setup
4. [ ] Repository access

### Scheduled (Pre-Launch)

1. [ ] Domain configuration
2. [ ] SSL certificates
3. [ ] Payment processing
4. [ ] Legal documents

### Deferred (Post-Launch)

1. [ ] Analytics setup
2. [ ] Advanced monitoring
3. [ ] App store submission
4. [ ] Marketing tools

## Time Investment Summary

| Category | Tasks | Total Time |
|----------|-------|------------|
| Platform Setup | 8 | 3-4 hours |
| API & Auth | 6 | 2-3 hours |
| Domain & Security | 5 | 1-2 hours |
| Testing | 3 | 3-5 hours |
| **Total** | **22** | **9-14 hours** |

## Notes & Recommendations

### For Agentic Developers

1. **Batch Similar Tasks**: Group platform signups to maintain flow
2. **Use Password Manager**: Essential for managing numerous credentials
3. **Document Everything**: Keep a secure record of all credentials
4. **Delegate When Possible**: Some tasks can be handled by team members
5. **Plan Ahead**: Many tasks have waiting periods (domain propagation, reviews)

### Common Pitfalls

- Forgetting to enable 2FA on critical accounts
- Not setting spending limits on pay-per-use services
- Missing DNS propagation time in deployment schedule
- Underestimating app store review times
- Not keeping development/staging/production configs in sync

## Completion Tracking

### Progress Indicators

- ⏳ Pending - Not started
- 🔄 In Progress - Currently working
- ⚠️ Blocked - Waiting on dependency
- ✅ Complete - Finished and verified
- 🚫 Skipped - Not applicable

### Verification Checklist

- [ ] All critical blockers resolved
- [ ] Credentials securely stored
- [ ] Team members have necessary access
- [ ] Documentation updated with configurations
- [ ] Backup/recovery plans in place

---

## Resources & Quick Links

### Platform Dashboards

- [Vercel Dashboard](https://vercel.com/dashboard)
- [Supabase Dashboard](https://app.supabase.com)
- [GCP Console](https://console.cloud.google.com)
- [AWS Console](https://aws.amazon.com/console/)
- [Stripe Dashboard](https://dashboard.stripe.com)

### Documentation

- [Vercel Docs](https://vercel.com/docs)
- [Supabase Docs](https://supabase.com/docs)
- [Next.js Deployment](https://nextjs.org/docs/deployment)
- [OAuth 2.0 Guide](https://oauth.net/2/)

### Security Resources

- [OWASP Checklist](https://owasp.org/www-project-application-security-verification-standard/)
- [Security Headers](https://securityheaders.com)
- [SSL Labs](https://www.ssllabs.com/ssltest/)

---

_Template Version: 1.0.0 | Human Tasks Framework | CC BY 4.0 License_