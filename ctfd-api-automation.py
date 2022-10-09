from requests import Session, post, get
import json
import logging
import jinja2
from os import environ

class ApiSession(Session):
    def __init__(self, ctfd_token, ctfd_host):
        """
        Define the headers and concatenate the API endpoint.
        """
        super().__init__()
        self.headers.update({
            "Authorization": f"Token {ctfd_token}",
            "Accept": "application/json",
            "Content-Type": "application/json"
        })
        self.ctfd_token = ctfd_token
        self.host: str = ctfd_host
        self.endpoint: str = self.host[:-1] + "/api/v1/" if (self.host[-1] == "/") else self.host + "/api/v1/"

    def get(self, url: str, params: any = None, **kwargs: any):
        """
        Versatile API requesting
        """
        url: str = self.endpoint + url
        return super().get(url, params=params, **kwargs)

    def get_challenges(self) -> dict:
        """
        Query the challenges endpoint to identify challenges.
        Returns a dictionary of solved challenges.
        """
        solved_challenges: dict = {}
        challenges: list = self.get("challenges").json()["data"]
        for challenge in challenges:
            # trying to parse data from hidden challenge throws errors
            if challenge["type"] == "hidden":
                continue
            solved_challenges[challenge["id"]] = challenge
        return solved_challenges

    def get_challenges_by_category(self) -> dict:
        """
        Query the challenges endpoint to identify challenges.
        Returns a dictionary of solved challenges.
        """
        if self.ctfd_token is None or self.host is None:
            print("Please define CTFd host and API token in environment variables.")
            exit(1)

        logging.debug(f"Proceeding with CTFD Token: {ctfd_token} and host {ctfd_host}")

        challenges = api.get_challenges()

        challenges_by_category = {}
        for challenge in challenges:
            if challenges[challenge]["category"] not in challenges_by_category.keys():
                challenges_by_category[challenges[challenge]["category"]] = []
            challenges_by_category[challenges[challenge]["category"]].append(challenges[challenge]["name"])

        if challenges_by_category == {}:
            logging.warning("No challenge categories found.")

        return challenges_by_category


def create_challenge_template(challenges_by_dictionary):
    """
    Use Jinja 2 to template first_note.md.jinja with CTF specific data.
    """
    template_loader = jinja2.FileSystemLoader(searchpath="./")
    template_env = jinja2.Environment(loader=template_loader)
    template_file = "first_note.md.jinja"
    template = template_env.get_template(template_file)
    output_text = template.render(challenges=challenges_by_dictionary)
    with open("first_note.md", "w") as f:
        f.write(output_text)


if __name__ == "__main__":
    # Define the CTFd host and API token
    ctfd_host = environ["CTFD_HOST"]
    ctfd_token = environ["CTFD_TOKEN"]
    ctf_name = environ["CTF_NAME"]

    api = ApiSession(ctfd_token, ctfd_host)
    challenge_dict = api.get_challenges_by_category()

    create_challenge_template(challenge_dict)

