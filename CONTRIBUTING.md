# Contributing to NGO Donation Platform

Thank you for your interest in contributing to the NGO Donation Platform! This document provides guidelines and instructions for contributing.

## Table of Contents
1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [How to Contribute](#how-to-contribute)
4. [Development Workflow](#development-workflow)
5. [Coding Standards](#coding-standards)
6. [Commit Guidelines](#commit-guidelines)
7. [Pull Request Process](#pull-request-process)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of background or identity.

### Expected Behavior

- Be respectful and considerate
- Welcome newcomers and help them get started
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Trolling or insulting/derogatory comments
- Public or private harassment
- Publishing others' private information
- Other conduct which could reasonably be considered inappropriate

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:
- Node.js (v16+) and npm installed
- Flutter SDK (v3.0+) installed
- MongoDB installed (or MongoDB Atlas account)
- Git installed and configured
- Code editor (VS Code recommended)

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/ngo-donation-platform.git
   cd ngo-donation-platform
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/ngo-donation-platform.git
   ```

### Setup Development Environment

```bash
# Install backend dependencies
cd backend
npm install
cp .env.example .env
# Edit .env with your local configuration

# Install frontend dependencies
cd ../frontend
flutter pub get

# Return to root
cd ..
```

---

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

#### 🐛 Bug Reports
- Use GitHub Issues
- Include detailed description
- Provide steps to reproduce
- Include screenshots if applicable
- Mention your environment (OS, browser, etc.)

#### 💡 Feature Requests
- Use GitHub Issues with "enhancement" label
- Describe the feature and its benefits
- Explain use cases
- Consider implementation complexity

#### 📝 Documentation
- Fix typos or unclear sections
- Add examples
- Improve API documentation
- Create tutorials or guides

#### 💻 Code Contributions
- Bug fixes
- New features
- Performance improvements
- Refactoring
- Tests

---

## Development Workflow

### 1. Create a Branch

Create a feature branch from `main`:

```bash
git checkout main
git pull upstream main
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/feature-name` - New features
- `bugfix/bug-description` - Bug fixes
- `docs/documentation-update` - Documentation changes
- `refactor/refactor-description` - Code refactoring
- `test/test-description` - Test additions/changes

### 2. Make Changes

- Write clean, readable code
- Follow coding standards (see below)
- Add tests for new features
- Update documentation as needed
- Test thoroughly

### 3. Commit Changes

```bash
git add .
git commit -m "feat: add user profile editing feature"
```

See [Commit Guidelines](#commit-guidelines) below.

### 4. Keep Your Branch Updated

```bash
git fetch upstream
git rebase upstream/main
```

### 5. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 6. Create Pull Request

- Go to GitHub and create a Pull Request
- Fill in the PR template
- Link related issues
- Request review from maintainers

---

## Coding Standards

### Backend (Node.js/Express)

#### Style Guide
- Use ES6+ features
- Use `const` and `let`, avoid `var`
- Use async/await instead of callbacks
- Use meaningful variable and function names
- Add JSDoc comments for functions

#### Example:
```javascript
/**
 * Get all active campaigns
 * @param {Object} filters - Filter criteria
 * @returns {Promise<Array>} Array of campaigns
 */
const getActiveCampaigns = async (filters = {}) => {
  try {
    const campaigns = await Campaign.find({ 
      status: 'active',
      ...filters 
    })
      .populate('ngo')
      .sort({ createdAt: -1 });
    
    return campaigns;
  } catch (error) {
    throw new Error(`Failed to fetch campaigns: ${error.message}`);
  }
};
```

#### File Structure
- One model per file
- One controller per resource
- Group related routes
- Keep files under 300 lines

### Frontend (Flutter/Dart)

#### Style Guide
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use meaningful widget names
- Extract reusable widgets
- Use `const` constructors where possible
- Add comments for complex logic

#### Example:
```dart
/// A card widget displaying campaign information
class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onTap;

  const CampaignCard({
    Key? key,
    required this.campaign,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildContent(),
            _buildProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return CachedNetworkImage(
      imageUrl: campaign.imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  // ... other methods
}
```

#### File Structure
- One screen per file
- Group related widgets
- Keep widgets under 200 lines
- Extract complex widgets to separate files

### General Guidelines

- **DRY (Don't Repeat Yourself)** - Extract reusable code
- **KISS (Keep It Simple, Stupid)** - Prefer simple solutions
- **YAGNI (You Aren't Gonna Need It)** - Don't add unnecessary features
- **Single Responsibility** - Each function/class should do one thing well

---

## Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements

### Examples

```bash
# Feature
git commit -m "feat(campaigns): add location-based filtering"

# Bug fix
git commit -m "fix(donations): resolve payment verification issue"

# Documentation
git commit -m "docs(api): update authentication endpoints"

# Refactoring
git commit -m "refactor(auth): simplify token validation logic"

# With body and footer
git commit -m "feat(volunteer): add badge system

Implement gamification for volunteers with badges
earned based on hours logged and activities completed.

Closes #123"
```

### Commit Best Practices

- Use present tense ("add feature" not "added feature")
- Use imperative mood ("move cursor to..." not "moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests in footer
- Explain *what* and *why*, not *how*

---

## Pull Request Process

### Before Submitting

- [ ] Code follows project style guidelines
- [ ] Self-review of code completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests added/updated and passing
- [ ] No console errors or warnings
- [ ] Branch is up to date with main

### PR Template

When creating a PR, include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Fixes #123

## Testing
Describe testing performed

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No new warnings
```

### Review Process

1. **Automated Checks**: CI/CD pipeline runs tests
2. **Code Review**: Maintainers review code
3. **Feedback**: Address review comments
4. **Approval**: At least one maintainer approval required
5. **Merge**: Maintainer merges PR

### After Merge

- Delete your feature branch
- Update your local main branch
- Close related issues (if not auto-closed)

---

## Testing Guidelines

### Backend Tests

```javascript
// tests/campaign.test.js
const request = require('supertest');
const app = require('../server');

describe('Campaign API', () => {
  let authToken;

  beforeAll(async () => {
    // Setup: login and get token
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'password' });
    authToken = res.body.token;
  });

  it('should get all campaigns', async () => {
    const res = await request(app)
      .get('/api/campaigns')
      .set('Authorization', `Bearer ${authToken}`);
    
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  // More tests...
});
```

### Frontend Tests

```dart
// test/widgets/campaign_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ngo_donation_app/widgets/campaign_card.dart';

void main() {
  group('CampaignCard', () {
    testWidgets('displays campaign information', (tester) async {
      final campaign = Campaign(
        title: 'Test Campaign',
        targetAmount: 100000,
        raisedAmount: 50000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CampaignCard(
              campaign: campaign,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Campaign'), findsOneWidget);
      expect(find.text('₹100,000'), findsOneWidget);
    });
  });
}
```

---

## Getting Help

### Resources

- **Documentation**: Check `/docs` folder
- **Issues**: Search existing issues on GitHub
- **Discussions**: Use GitHub Discussions for questions
- **Email**: contact@example.com

### Questions?

If you have questions:
1. Check documentation first
2. Search existing issues
3. Ask in GitHub Discussions
4. Create a new issue with "question" label

---

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project website (if applicable)

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to make this project better! 🎉**
