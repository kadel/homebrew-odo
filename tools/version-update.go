package main

import (
	"context"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"regexp"
	"strings"

	"github.com/Masterminds/semver"
	"github.com/google/go-github/v32/github"
	"golang.org/x/oauth2"
)

func getFormulaInfo(formulaFile string) (string, string, error) {
	var tagRe = regexp.MustCompile(`:tag\s+=>\s+"([^"]*)"`)
	var revisionRe = regexp.MustCompile(`:revision\s+=>\s+"([^"]*)"`)
	var tag string
	var revision string

	content, err := ioutil.ReadFile(formulaFile)
	if err != nil {
		return "", "", err
	}

	tagFind := tagRe.FindAllSubmatch(content, -1)
	if len(tagFind) == 1 && len(tagFind[0]) == 2 {
		tag = string(tagFind[0][1])
	} else {
		return "", "", fmt.Errorf("unable to match tag in the formula file")
	}
	revisionFind := revisionRe.FindAllSubmatch(content, -1)
	if len(revisionFind) == 1 && len(revisionFind[0]) == 2 {
		revision = string(revisionFind[0][1])
	} else {

		return "", "", fmt.Errorf("unable to match revision in the formula file")
	}

	return tag, revision, nil

}

// getLatestRelease returns tag and revision of the latest release in the repo
func getLatestRelease(org string, repo string, token string) (string, string, error) {
	var releaseTag string
	var releaseRevision string
	var tc *http.Client
	ctx := context.Background()
	if token != "" {
		ts := oauth2.StaticTokenSource(
			&oauth2.Token{AccessToken: token},
		)
		tc = oauth2.NewClient(ctx, ts)
	}
	gh := github.NewClient(tc)
	release, _, err := gh.Repositories.GetLatestRelease(ctx, org, repo)
	if err != nil {
		return "", "", err
	}
	releaseTag = release.GetTagName()

	opt := &github.ListOptions{PerPage: 100}
	var allTags []*github.RepositoryTag
	for {
		tags, resp, err := gh.Repositories.ListTags(ctx, org, repo, opt)
		if err != nil {
			return "", "", err
		}
		allTags = append(allTags, tags...)
		if resp.NextPage == 0 {
			break
		}
		opt.Page = resp.NextPage
	}
	// find tag matching latest release
	for _, tag := range allTags {
		if releaseTag == tag.GetName() {
			releaseRevision = tag.GetCommit().GetSHA()
			break
		}
	}
	if releaseRevision == "" {
		return "", "", fmt.Errorf("unable to find release tag in git tags")
	}
	return releaseTag, releaseRevision, nil
}

func updateFormula(formulaFile string, tag string, revision string) error {
	var tagRe = regexp.MustCompile(`(:tag\s+=>\s+")([^"]*)(")`)
	var revisionRe = regexp.MustCompile(`(:revision\s+=>\s+")([^"]*)(")`)

	content, err := ioutil.ReadFile(formulaFile)
	if err != nil {
		return err
	}
	content = tagRe.ReplaceAll(content, []byte(fmt.Sprintf("${1}%s${3}", tag)))
	content = revisionRe.ReplaceAll(content, []byte(fmt.Sprintf("${1}%s${3}", revision)))

	log.Println("Updated formula:")
	log.Printf("\n%s\n", content)

	err = ioutil.WriteFile(formulaFile, content, 0644)
	if err != nil {
		return err
	}
	return nil
}

func main() {
	var formulaFile string
	var repo string
	var org string
	var token string
	flag.StringVar(&formulaFile, "formulaFile", "", "Path to Homebrew formula file.")
	flag.StringVar(&repo, "repo", "", "Name of the repo to check.")
	flag.StringVar(&org, "org", "", "Name of the org where repo is.")
	flag.StringVar(&token, "token", "", "GitHub token.")
	flag.Parse()

	if formulaFile == "" || repo == "" || org == "" {
		fmt.Println("-formulaFile, -repo, -org are required flags")
		os.Exit(1)
	}

	formulaTag, formulaRevision, err := getFormulaInfo(formulaFile)
	if err != nil {
		panic(err)
	}
	log.Printf("Formula information: tag=%s, revision=%s\n", formulaTag, formulaRevision)

	releaseTag, releaseRevision, err := getLatestRelease(org, repo, token)
	if err != nil {
		panic(err)
	}
	log.Printf("Latest release information: tag=%s, revision=%s\n", releaseTag, releaseRevision)

	isLatest, err := semver.NewConstraint(fmt.Sprintf("= %s", strings.Replace(releaseTag, "v", "", 1)))
	if err != nil {
		panic(err)
	}
	formulaVersion, err := semver.NewVersion(strings.Replace(formulaTag, "v", "", 1))
	if err != nil {
		panic(err)
	}
	if !isLatest.Check(formulaVersion) {
		log.Println("Formula doesn't use the latest release. UPDATING ....")
		err = updateFormula(formulaFile, releaseTag, releaseRevision)
		if err != nil {
			panic(err)
		}
	} else {
		log.Println("Formula already uses the latest release.")
	}
	os.Exit(0)

}
