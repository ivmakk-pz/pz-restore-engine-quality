# Post-Release Finalization

## Instructions
This prompt finalizes the release after completing the release preparation. Execute these steps to merge and tag the release.

## Step 1: Complete Git Release Workflow
Execute the git release workflow after completing the release preparation:

1. **Merge to Master**:
   ```
   git checkout master
   git merge release/[VERSION]
   ```

2. **Check Existing Tag Format** (IMPORTANT):
   ```
   git tag --sort=-version:refname
   ```
   Review the format of existing tags to ensure consistency. Use the same format (with or without 'v' prefix) as existing tags.

3. **Create and Push Tag**:
   ```
   git tag [VERSION]
   git push origin master
   git push origin [VERSION]
   ```
3. **Create and Push Tag**:
   ```
   git tag [VERSION]
   git push origin master
   git push origin [VERSION]
   ```
   Note: Use version format that matches existing tags (e.g., '2.0.0' not 'v2.0.0' if existing tags use no prefix)

4. **Clean Up Release Branch**:
   ```
   git branch -d release/[VERSION]
   git push origin --delete release/[VERSION]
   ```

5. **Verify Completion**:
   ```
   git status
   git tag --sort=-version:refname
   ```

## Step 2: Verify Release Completion
- Confirm you are on master branch
- Verify latest tag matches released version
- Ensure release branch has been cleaned up
- Check that working tree is clean

## Expected Outcome
After execution:
- Release branch merged to master with tag
- Clean repository state on master branch
- Release is finalized and tagged on GitHub

**🎉 Release is now complete and tagged on GitHub!**

You can now:
- Create a GitHub release if desired
- Start working on the next version when ready

---

**Execute this post-release finalization now to complete the release.**